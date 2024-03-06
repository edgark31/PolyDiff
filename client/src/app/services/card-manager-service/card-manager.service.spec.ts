import { TestBed } from '@angular/core/testing';

import { CardManagerService } from './card-manager.service';

describe('CardManagerService', () => {
  let service: CardManagerService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CardManagerService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
