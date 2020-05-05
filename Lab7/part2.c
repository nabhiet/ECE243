#include <stdlib.h>
#include <stdbool.h>
volatile int pixel_buffer_start; // global variable

void clear_screen();
void draw_line(int x0, int y0, int x1, int y1, short int clr); 
void swap(int *x, int *y); 
void plot_pixel(int x, int y, short int line_color);
void wait_for_vsync();

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
	int y = 0;
    draw_line(60, y, 260, y, 0x821d);   // this line is purple
	int y_step = 1;
	
	while(1){
		draw_line(60, y, 260, y, 0x0000); // erase line
		y = y + y_step;
		if(y == 0) y_step = 1; // add when line reaches top edge
		else if(y == 239) y_step = -1; // subtract when line reaches bottom edge
		draw_line(60, y, 260, y, 0x821d); // redraw one row above/below
		wait_for_vsync();
	}
}

void clear_screen()
{
	for(int x = 0; x < 320; ++x) {
		for(int y = 0; y < 240; ++y) {
			plot_pixel(x, y, 0x0000);
		}
	}
}

void draw_line(int x0, int y0, int x1, int y1, short int clr) 
{
	bool is_steep = abs(y1 - y0) > abs(x1 - x0);
	
	if(is_steep) {
		swap(&x0, &y0);
		swap(&x1, &y1);
	}
	if(x0 > x1) {
		swap(&x0, &x1);
		swap(&y0, &y1);
	}
	
	int deltax = x1 - x0;
	int deltay = abs(y1 - y0);
	int error = -(deltax / 2);
	int y = y0;
	int y_step = 0;
	if(y0 < y1) y_step = 1;
	else y_step = -1;
	
	for(int x = x0; x < x1; ++x) {
		if(is_steep) plot_pixel(y, x, clr);
		else plot_pixel(x, y, clr);
		error = error + deltay;
		if(error >= 0) {
			y = y + y_step;
			error = error - deltax;
		}
	}
}

void swap(int *x, int *y) 
{
	int temp = *x; 
    *x = *y; 
    *y = temp;
}

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

void wait_for_vsync()
{
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020; // pixel controller
	register int status;
	
	*pixel_ctrl_ptr = 1; // start the synchronization process
	
	status = *(pixel_ctrl_ptr + 3);
	while((status & 0x01) != 0) {
		status = *(pixel_ctrl_ptr + 3);
	}
}
