import { RecordManagerService } from '@app/services/record-manager/record-manager.service';
import { GameRecord } from '@common/game-interfaces';
import { Controller, Delete, Get, Param, Put, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('GameRecords')
@Controller('records')
export class RecordController {
    constructor(private readonly recordManagerService: RecordManagerService) {}

    @Get(':accountId')
    async findAllByAccountId(@Param('accountId') accountId?: string): Promise<GameRecord[]> {
        const records = await this.recordManagerService.findAllByAccountId(accountId);
        return records;
    }

    @Get(':date')
    async findOneByDate(@Param('date') date: Date): Promise<GameRecord> {
        return await this.recordManagerService.findOne(date);
    }

    @Put(':date')
    updateAccountIds(@Param('date') date: string, @Query('accountId') accountId: string): void {
        this.recordManagerService.addAccountId(date, accountId);
    }

    @Delete(':date')
    deleteAccountId(@Param('date') date: string, @Query('accountId') accountId: string): void {
        this.recordManagerService.deleteAccountId(date, accountId);
    }

    @Delete() // delete all records
    deleteAll(): void {
        this.recordManagerService.deleteAll();
    }
}
