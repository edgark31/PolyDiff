import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CreateRoomPageComponent } from './create-room-page.component';

describe('CreateRoomPageComponent', () => {
  let component: CreateRoomPageComponent;
  let fixture: ComponentFixture<CreateRoomPageComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CreateRoomPageComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CreateRoomPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
