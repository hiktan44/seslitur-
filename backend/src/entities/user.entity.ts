import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToMany,
  JoinTable,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { Group } from './group.entity';
import { Session } from './session.entity';
import { UserStatus } from '../interfaces/user-status.enum';
import { Role } from '../interfaces/role.enum';

/**
 * Kullanıcı Varlık Modeli
 * 
 * Sistemdeki kullanıcıları temsil eden varlık sınıfı
 */
@Entity('users')
export class User {
  /**
   * Benzersiz kullanıcı kimliği
   */
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * Kullanıcının e-posta adresi (benzersiz)
   */
  @Column({ unique: true })
  email: string;

  /**
   * Kullanıcının telefon numarası (opsiyonel)
   */
  @Column({ nullable: true })
  phoneNumber: string;

  /**
   * Kullanıcının şifrelenmiş parolası
   */
  @Column()
  @Exclude()
  passwordHash: string;

  /**
   * Kullanıcının adı
   */
  @Column()
  firstName: string;

  /**
   * Kullanıcının soyadı
   */
  @Column()
  lastName: string;

  /**
   * Kullanıcının profil resmi URL'si
   */
  @Column({ nullable: true })
  profilePicture: string;

  /**
   * Kullanıcının durumu (aktif, pasif, askıda)
   */
  @Column({
    type: 'enum',
    enum: UserStatus,
    default: UserStatus.ACTIVE,
  })
  status: UserStatus;

  /**
   * Kullanıcının rolleri
   */
  @Column({
    type: 'enum',
    enum: Role,
    array: true,
    default: [Role.USER],
  })
  roles: Role[];

  /**
   * Kullanıcının bildirim ayarları
   */
  @Column({ type: 'jsonb', default: {} })
  notificationSettings: Record<string, any>;

  /**
   * Kullanıcının ses ayarları
   */
  @Column({ type: 'jsonb', default: {} })
  audioSettings: Record<string, any>;

  /**
   * Kullanıcının tercih ettiği dil
   */
  @Column({ default: 'tr' })
  language: string;

  /**
   * Kullanıcının zaman dilimi
   */
  @Column({ default: 'Europe/Istanbul' })
  timezone: string;

  /**
   * Kullanıcının oluşturduğu gruplar
   */
  @OneToMany(() => Group, (group) => group.owner)
  ownedGroups: Group[];

  /**
   * Kullanıcının üye olduğu gruplar
   */
  @ManyToMany(() => Group, (group) => group.members)
  @JoinTable({
    name: 'user_groups',
    joinColumn: { name: 'user_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'group_id', referencedColumnName: 'id' },
  })
  groups: Group[];

  /**
   * Kullanıcının katıldığı oturumlar
   */
  @ManyToMany(() => Session, (session) => session.participants)
  @JoinTable({
    name: 'user_sessions',
    joinColumn: { name: 'user_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'session_id', referencedColumnName: 'id' },
  })
  sessions: Session[];

  /**
   * Kullanıcının son giriş tarihi
   */
  @Column({ nullable: true })
  lastLoginAt: Date;

  /**
   * Kullanıcının oluşturulma tarihi
   */
  @CreateDateColumn()
  createdAt: Date;

  /**
   * Kullanıcının son güncellenme tarihi
   */
  @UpdateDateColumn()
  updatedAt: Date;

  /**
   * Kullanıcının tam adını döndürür
   */
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }
} 