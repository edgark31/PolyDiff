import { Coordinate } from '@common/coordinate';
export declare class CreateGameDto {
    name: string;
    originalImage: string;
    modifiedImage: string;
    nDifference: number;
    differences: Coordinate[][];
    isHard: boolean;
}
