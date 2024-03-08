import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CreateRoomnComponent } from './create-roomn.component';

describe('CreateRoomnComponent', () => {
  let component: CreateRoomnComponent;
  let fixture: ComponentFixture<CreateRoomnComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CreateRoomnComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CreateRoomnComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
