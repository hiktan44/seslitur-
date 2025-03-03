import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  ManyToMany,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Group } from './group.entity';
import { SessionStatus } from '../interfaces/session-status.enum';

/**
 * Oturum Varlık Modeli
 * 
 * Sistemdeki sesli iletişim oturumlarını temsil eden varlık sınıfı
 */
@Entity('sessions')
export class Session {
  /**
   * Benzersiz oturum kimliği
   */
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * Oturum adı
   */
  @Column()
  name: string;

  /**
   * Oturum açıklaması
   */
  @Column({ nullable: true, type: 'text' })
  description: string;

  /**
   * Oturumun bağlı olduğu grup
   */
  @ManyToOne(() => Group, (group) => group.sessions)
  @JoinColumn({ name: 'group_id' })
  group: Group;

  /**
   * Oturumun bağlı olduğu grup ID
   */
  @Column({ name: 'group_id' })
  groupId: string;

  /**
   * Oturum başlatıcısı
   */
  @ManyToOne(() => User)
  @JoinColumn({ name: 'creator_id' })
  creator: User;

  /**
   * Oturum başlatıcısı ID
   */
  @Column({ name: 'creator_id' })
  creatorId: string;

  /**
   * Oturum katılımcıları
   */
  @ManyToMany(() => User, (user) => user.sessions)
  participants: User[];

  /**
   * Aktif konuşmacı ID
   */
  @Column({ nullable: true })
  activeSpeakerId: string;

  /**
   * Oturum durumu
   */
  @Column({
    type: 'enum',
    enum: SessionStatus,
    default: SessionStatus.SCHEDULED,
  })
  status: SessionStatus;

  /**
   * Planlanan başlangıç zamanı
   */
  @Column({ nullable: true })
  scheduledStartTime: Date;

  /**
   * Gerçek başlangıç zamanı
   */
  @Column({ nullable: true })
  actualStartTime: Date;

  /**
   * Bitiş zamanı
   */
  @Column({ nullable: true })
  endTime: Date;

  /**
   * Maksimum süre (dakika)
   */
  @Column({ default: 60 })
  maxDuration: number;

  /**
   * Kayıt URL'si
   */
  @Column({ nullable: true })
  recordingUrl: string;

  /**
   * Oturum ayarları
   */
  @Column({ type: 'jsonb', default: {} })
  settings: Record<string, any>;

  /**
   * Oturumun oluşturulma tarihi
   */
  @CreateDateColumn()
  createdAt: Date;

  /**
   * Oturumun son güncellenme tarihi
   */
  @UpdateDateColumn()
  updatedAt: Date;
} 