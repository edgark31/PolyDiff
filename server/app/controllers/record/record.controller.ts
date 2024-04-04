import { RecordManagerService } from '@app/services/record-manager/record-manager.service';
import { GameRecord } from '@common/game-interfaces';
import { Controller, Delete, Get, Param, Put, Query } from '@nestjs/common';

@Controller('records')
export class RecordController {
    constructor(private readonly recordManagerService: RecordManagerService) {}

    @Get(':date')
    async findOneByDate(@Param('date') date: Date): Promise<GameRecord> {
        return await this.recordManagerService.findOne(date);
    }

    @Get()
    async findAllByAccountId(@Query('accountId') accountId?: string): Promise<GameRecord[]> {
        return await this.recordManagerService.findAllByAccountId(accountId);
    }

    @Put(':date')
    updateAccountIds(@Param('date') date: string, @Query('accountId') accountId: string): void {
        this.recordManagerService.addAccountId(date, accountId);
    }

    @Delete(':date')
    deleteAccountId(@Param('date') date: string, @Query('accountId') accountId: string): void {
        this.recordManagerService.deleteAccountId(date, accountId);
    }
}
