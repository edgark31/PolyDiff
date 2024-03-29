import { Test, TestingModule } from '@nestjs/testing';
import { FriendManagerService } from './friend-manager.service';

describe('FriendManagerService', () => {
    let service: FriendManagerService;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [FriendManagerService],
        }).compile();

        service = module.get<FriendManagerService>(FriendManagerService);
    });

    it('should be defined', () => {
        expect(service).toBeDefined();
    });
});
