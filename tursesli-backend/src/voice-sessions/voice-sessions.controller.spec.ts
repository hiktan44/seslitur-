import { Test, TestingModule } from '@nestjs/testing';
import { VoiceSessionsController } from './voice-sessions.controller';

describe('VoiceSessionsController', () => {
  let controller: VoiceSessionsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [VoiceSessionsController],
    }).compile();

    controller = module.get<VoiceSessionsController>(VoiceSessionsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
