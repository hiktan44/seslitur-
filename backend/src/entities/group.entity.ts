import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToMany,
  JoinTable,
  OneToMany,
} from 'typeorm';
import { User } from './user.entity';
import { Session } from './session.entity';

/**
 * Grup Varlık Modeli
 * 
 * Sistemdeki kullanıcı gruplarını temsil eden varlık sınıfı
 */
@Entity('groups')
export class Group {
  /**
   * Benzersiz grup kimliği
   */
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * Grup adı
   */
  @Column()
  name: string;

  /**
   * Grup açıklaması
   */
  @Column({ nullable: true, type: 'text' })
  description: string;

  /**
   * Grup resmi URL'si
   */
  @Column({ nullable: true })
  imageUrl: string;

  /**
   * Grup şifresi (şifrelenmiş)
   */
  @Column({ nullable: true })
  passwordHash: string;

  /**
   * Grup üyeleri
   */
  @ManyToMany(() => User)
  @JoinTable({
    name: 'group_members',
    joinColumn: { name: 'group_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'user_id', referencedColumnName: 'id' },
  })
  members: User[];

  /**
   * Grup yöneticileri
   */
  @ManyToMany(() => User)
  @JoinTable({
    name: 'group_admins',
    joinColumn: { name: 'group_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'user_id', referencedColumnName: 'id' },
  })
  admins: User[];

  /**
   * Grup oturumları
   */
  @OneToMany(() => Session, (session) => session.group)
  sessions: Session[];

  /**
   * Maksimum üye sayısı
   */
  @Column({ default: 100 })
  maxMembers: number;

  /**
   * Grup ayarları
   */
  @Column({ type: 'jsonb', default: {} })
  settings: Record<string, any>;

  /**
   * Grubun oluşturulma tarihi
   */
  @CreateDateColumn()
  createdAt: Date;

  /**
   * Grubun son güncellenme tarihi
   */
  @UpdateDateColumn()
  updatedAt: Date;
} 