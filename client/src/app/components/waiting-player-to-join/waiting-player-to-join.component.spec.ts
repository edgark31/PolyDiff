import { ComponentFixture, TestBed } from '@angular/core/testing';

import { WaitingPlayerToJoinComponent } from './waiting-player-to-join.component';

describe('WaitingPlayerToJoinComponent', () => {
  let component: WaitingPlayerToJoinComponent;
  let fixture: ComponentFixture<WaitingPlayerToJoinComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ WaitingPlayerToJoinComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(WaitingPlayerToJoinComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
