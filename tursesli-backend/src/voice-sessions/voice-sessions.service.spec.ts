import { Test, TestingModule } from '@nestjs/testing';
import { VoiceSessionsService } from './voice-sessions.service';

describe('VoiceSessionsService', () => {
  let service: VoiceSessionsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [VoiceSessionsService],
    }).compile();

    service = module.get<VoiceSessionsService>(VoiceSessionsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
