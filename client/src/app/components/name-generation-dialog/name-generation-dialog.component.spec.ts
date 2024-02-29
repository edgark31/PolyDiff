import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NameGenerationDialogComponent } from './name-generation-dialog.component';

describe('NameGenerationDialogComponent', () => {
    let component: NameGenerationDialogComponent;
    let fixture: ComponentFixture<NameGenerationDialogComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            declarations: [NameGenerationDialogComponent],
        }).compileComponents();

        fixture = TestBed.createComponent(NameGenerationDialogComponent);
        component = fixture.componentInstance;
        fixture.detectChanges();
    });

    it('should create', () => {
        expect(component).toBeTruthy();
    });
});
