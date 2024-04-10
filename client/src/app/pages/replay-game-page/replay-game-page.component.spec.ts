import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ReplayGamePageComponent } from './replay-game-page.component';

describe('ReplayGamePageComponent', () => {
  let component: ReplayGamePageComponent;
  let fixture: ComponentFixture<ReplayGamePageComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ReplayGamePageComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ReplayGamePageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
