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
	// declare other variables(not shown)
	int N = 8;
	short int color[10] = {0x8770, 0xff63, 0xf883, 0xf897, 0x247f, 0xfc41, 0xfac2, 0xffff, 0x27ff, 0x23a1};
    short int color_box[N];
	int dx_box[N];
	int dy_box[N];
	int x_box[N];
	int y_box[N];
	int x_box_last[N];
	int y_box_last[N];
    // initialize location and direction of rectangles
	for(int i = 0; i < N; ++i) {
		color_box[i] = color[rand() % 10];
		dx_box[i] = rand() % 2 * 2 - 1;
		dy_box[i] = rand() % 2 * 2 - 1;
		x_box[i] = rand() % 317;
		y_box[i] = rand() % 237;
		x_box_last[i] = x_box[i];
		y_box_last[i] = y_box[i];
	}

    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
	clear_screen();
    
	while (1) {
        /* Erase any boxes and lines that were drawn in the last iteration */
        for(int i = 0; i < N; ++i) {
			for(int x = 0; x < 3; ++x) {
				for(int y = 0; y < 3; ++y) {
					plot_pixel(x_box_last[i]+x, y_box_last[i]+y, 0x0000);
				}
			}
			draw_line(x_box_last[i], y_box_last[i], x_box_last[(i+1)%N], y_box_last[(i+1)%N], 0x0000);
		}
		
		// save current x, y coordinates
		for(int i = 0; i < N; ++i) {
			x_box_last[i] = x_box[i];
			y_box_last[i] = y_box[i];
		}
		
		// update the locations of boxes
		for(int i = 0; i < N; ++i) {
			if(x_box[i] == 0 || x_box[i] == 317) dx_box[i] *= -1;
			if(y_box[i] == 0 || y_box[i] == 237) dy_box[i] *= -1;
			x_box[i] += dx_box[i];
			y_box[i] += dy_box[i];
		}
		
        // draw the boxes and lines
		for(int i = 0; i < N; ++i) {
			for(int x = 0; x < 3; ++x) {
				for(int y = 0; y < 3; ++y) {
					plot_pixel(x_box[i]+x, y_box[i]+y, 0xFFFF);
				}
			}
			draw_line(x_box[i], y_box[i], x_box[(i+1)%N], y_box[(i+1)%N], color_box[i]);
		}
		
        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

void clear_screen() {
	for(int x = 0; x < 320; ++x) {
		for(int y = 0; y < 240; ++y) {
			plot_pixel(x, y, 0x0000);
		}
	}
}

void draw_line(int x0, int y0, int x1, int y1, short int clr) {
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

void swap(int *x, int *y) {
	int temp = *x; 
    *x = *y; 
    *y = temp;
}

void plot_pixel(int x, int y, short int line_color) {
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

void wait_for_vsync() {
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020; // pixel controller
	register int status;
	
	*pixel_ctrl_ptr = 1; // start the synchronization process
	
	status = *(pixel_ctrl_ptr + 3);
	while((status & 0x01) != 0) {
		status = *(pixel_ctrl_ptr + 3);
	}
}


	