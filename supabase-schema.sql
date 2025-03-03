-- TurSesli Veritabanı Şeması

-- Users Tablosu (Supabase Auth ile entegre)
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone_number TEXT,
    role TEXT NOT NULL CHECK (role IN ('guide', 'participant', 'admin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Users için RLS (Row Level Security) Politikaları
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Kullanıcılar kendi profillerini görebilir" 
    ON public.users FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Kullanıcılar kendi profillerini düzenleyebilir" 
    ON public.users FOR UPDATE 
    USING (auth.uid() = id);

CREATE POLICY "Adminler tüm kullanıcıları yönetebilir" 
    ON public.users 
    USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

-- Tours Tablosu
CREATE TABLE public.tours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    destination TEXT NOT NULL,
    guide_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('upcoming', 'active', 'completed', 'cancelled')),
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_date_range CHECK (start_date < end_date)
);

-- Tours için RLS Politikaları
ALTER TABLE public.tours ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Herkes turları görebilir" 
    ON public.tours FOR SELECT 
    TO authenticated 
    USING (true);

CREATE POLICY "Rehberler kendi turlarını düzenleyebilir" 
    ON public.tours FOR UPDATE 
    USING (auth.uid() = guide_id);

CREATE POLICY "Rehberler ve adminler tur oluşturabilir" 
    ON public.tours FOR INSERT 
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND (role = 'guide' OR role = 'admin')
    ));

CREATE POLICY "Rehberler kendi turlarını silebilir" 
    ON public.tours FOR DELETE 
    USING (auth.uid() = guide_id);

-- Tour Participants Tablosu (Çoka-Çok ilişki)
CREATE TABLE public.tour_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES public.tours(id) ON DELETE CASCADE,
    participant_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(tour_id, participant_id)
);

-- Tour Participants için RLS Politikaları
ALTER TABLE public.tour_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Herkes katılımcıları görebilir" 
    ON public.tour_participants FOR SELECT 
    TO authenticated 
    USING (true);

CREATE POLICY "Katılımcılar turlara katılabilir" 
    ON public.tour_participants FOR INSERT 
    WITH CHECK (
        auth.uid() = participant_id AND 
        EXISTS (SELECT 1 FROM public.tours WHERE id = tour_id AND status IN ('upcoming', 'active'))
    );

CREATE POLICY "Katılımcılar turdan ayrılabilir" 
    ON public.tour_participants FOR DELETE 
    USING (auth.uid() = participant_id);

-- Voice Sessions Tablosu
CREATE TABLE public.voice_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES public.tours(id) ON DELETE CASCADE,
    started_by UUID NOT NULL REFERENCES public.users(id),
    start_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_time TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'ended')),
    audio_quality TEXT NOT NULL DEFAULT 'medium' CHECK (audio_quality IN ('low', 'medium', 'high')),
    participants_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT check_end_time CHECK (end_time IS NULL OR end_time > start_time)
);

-- Voice Sessions için RLS Politikaları
ALTER TABLE public.voice_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Herkes sesli oturumları görebilir" 
    ON public.voice_sessions FOR SELECT 
    TO authenticated 
    USING (true);

CREATE POLICY "Rehberler sesli oturum başlatabilir" 
    ON public.voice_sessions FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.tours 
            WHERE id = tour_id AND guide_id = auth.uid() AND status = 'active'
        )
    );

CREATE POLICY "Rehberler kendi sesli oturumlarını güncelleyebilir" 
    ON public.voice_sessions FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM public.tours 
            WHERE id = tour_id AND guide_id = auth.uid()
        )
    );

CREATE POLICY "Rehberler kendi sesli oturumlarını silebilir" 
    ON public.voice_sessions FOR DELETE 
    USING (
        EXISTS (
            SELECT 1 FROM public.tours 
            WHERE id = tour_id AND guide_id = auth.uid()
        )
    );

-- Güncelleme Triggerları
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_modtime
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_tours_modtime
BEFORE UPDATE ON public.tours
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_voice_sessions_modtime
BEFORE UPDATE ON public.voice_sessions
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- Tur Durumu Otomatik Güncelleme Fonksiyonu
CREATE OR REPLACE FUNCTION update_tour_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Eğer tur başlangıç tarihi geçtiyse ve durum "upcoming" ise "active" olarak güncelle
    IF NEW.status = 'upcoming' AND NEW.start_date <= NOW() THEN
        NEW.status := 'active';
    END IF;
    -- Eğer tur bitiş tarihi geçtiyse ve durum "active" ise "completed" olarak güncelle
    IF NEW.status = 'active' AND NEW.end_date <= NOW() THEN
        NEW.status := 'completed';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_tour_status_trigger
BEFORE INSERT OR UPDATE ON public.tours
FOR EACH ROW EXECUTE PROCEDURE update_tour_status();

-- Voice Session Katılımcı Sayacı Fonksiyonları
CREATE OR REPLACE FUNCTION increment_participants_count(session_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE public.voice_sessions
    SET participants_count = participants_count + 1
    WHERE id = session_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_participants_count(session_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE public.voice_sessions
    SET participants_count = GREATEST(0, participants_count - 1)
    WHERE id = session_id;
END;
$$ LANGUAGE plpgsql;

-- Voice Session Sona Erdirme Fonksiyonu
CREATE OR REPLACE FUNCTION end_voice_session(session_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE public.voice_sessions
    SET 
        status = 'ended',
        end_time = NOW()
    WHERE id = session_id AND status = 'active';
END;
$$ LANGUAGE plpgsql; 