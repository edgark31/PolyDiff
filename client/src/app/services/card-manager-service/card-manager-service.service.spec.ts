import { TestBed } from '@angular/core/testing';

import { CardManagerServiceService } from './card-manager-service.service';

describe('CardManagerServiceService', () => {
  let service: CardManagerServiceService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CardManagerServiceService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
