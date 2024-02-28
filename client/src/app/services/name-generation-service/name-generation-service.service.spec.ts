import { TestBed } from '@angular/core/testing';

import { NameGenerationServiceService } from './name-generation-service.service';

describe('NameGenerationServiceService', () => {
    let service: NameGenerationServiceService;

    beforeEach(() => {
        TestBed.configureTestingModule({});
        service = TestBed.inject(NameGenerationServiceService);
    });

    it('should be created', () => {
        expect(service).toBeTruthy();
    });
});
