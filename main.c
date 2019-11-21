//Xianghui Liu
//Nov 19 2019
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>  //显示窗口
#include <conio.h> //键盘输入
#include <time.h>
#include <unistd.h>

//窗口高和宽 
#define FRAME_height 30
#define FRAME_width 16

//#define BLOCK FRAME_width/10
#define BLOCK 2
//窗口左上角坐标 
#define FrameX 10
#define FrameY 5

#define AX (FRAME_width/BLOCK + 1)
#define AY (FRAME_height/BLOCK + 1)
//起始方块位置 
#define START_OFFSET_X  AX/2
#define START_OFFSET_Y  1

int a[FRAME_width / BLOCK + 1][FRAME_height / BLOCK + 1] = {0}; //0: nothing; 1: 方块； 2：边框. a[0:][0:]永远不使用 
int b[4] = {0}; //0: nothing; 1: 方块
int score = 0;

typedef struct{
	int x[4];
	int y[4];
	int flag; //方块种类  
	int speed; //下降速度  
	int level; //游戏等级 
} Tetris;

HANDLE hOut; //控制台句柄 
 
/* run this program using the console pauser or add your own getch, system("pause") or input loop */

void gotoxy(int x, int y){
	COORD pos;
	pos.X = x;
	pos.Y = y;
	SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), pos);
}

void DrawGameFrame(){
	
	//打印顶点 
	gotoxy(FrameX, FrameY);
	printf("*");
	gotoxy(FrameX + FRAME_width + 1, FrameY);
	printf("*");
	gotoxy(FrameX, FrameY + FRAME_height + 1);
	printf("*");
	gotoxy(FrameX + FRAME_width + 1, FrameY + FRAME_height + 1);
	printf("*");
	
	//打印边框
	int i;
	for(i = 1; i < FRAME_width + 1; i++){
		gotoxy(FrameX + i, FrameY);
		printf("-");
		gotoxy(FrameX + i, FrameY+ FRAME_height + 1);
		printf("-");
	}
	
	for(i = 1; i < FRAME_height + 1; i++){
		gotoxy(FrameX, FrameY + i);
		printf("|");
		gotoxy(FrameX + FRAME_width + 1, FrameY + i);
		printf("|");
	} 
}
 
//void printTetris(const Tetris * p){
//	int i, j, k;
//	for(i = 0; i < 4; i++){
//		for(j = 0; j < BLOCK; j++){
//			for(k = 0; k < BLOCK; k++){
//				gotoxy(p->x[i] + j + FrameX, p->y[i] + k + FrameY);
//				printf("*");
//			}
//		}
//	}
//}

void setBoard(const Tetris * p, int set){
	int i, j;
	for(i = 0; i < 4; i++){
		a[p->x[i]][p->y[i]] = set;
	}
}

void printBoard(){
	int i, j;
	for(i = 1; i < FRAME_width + 1; i++){
		for(j = 1; j < FRAME_height + 1; j++){
			gotoxy(i + FrameX, j + FrameY);
			if(a[(i + BLOCK - 1)/BLOCK][(j + BLOCK - 1)/BLOCK] == 1){
				printf("*");
			}
			else{
				printf(" ");
			} 
		}
	}	
}

void generateTetris(Tetris * p, int Ttype, int xloc, int yloc){
	p->x[0] = xloc;
	p->y[0] = yloc;
	
	if(Ttype == 1){
		p->x[1] = p->x[0] + 1;
		p->y[1] = p->y[0];
		p->x[2] = p->x[0];
		p->y[2] = p->y[0] + 1;
		p->x[3] = p->x[0] + 1;
		p->y[3] = p->y[0] + 1;
		p->flag = 1;	
	}
	
	if(Ttype == 20){
		p->x[1] = p->x[0] + 1;
		p->y[1] = p->y[0];
		p->x[2] = p->x[0] + 1;
		p->y[2] = p->y[0] + 1;
		p->x[3] = p->x[2] + 1;
		p->y[3] = p->y[2];
		p->flag = 20;
	}
	
	if(Ttype == 21){
		p->x[1] = p->x[0] + 1;
		p->y[1] = p->y[0] - 1;
		p->x[2] = p->x[0] + 1;
		p->y[2] = p->y[0];
		p->x[3] = p->x[0];
		p->y[3] = p->y[0]  + 1;
		p->flag = 21;
	}
	
	if(Ttype == 30){
		p->x[1] = p->x[0] + 1;
		p->y[1] = p->y[0];
		p->x[2] = p->x[1] + 1;
		p->y[2] = p->y[0];
		p->x[3] = p->x[2] + 1;
		p->y[3] = p->y[0];
		p->flag = 30;
	}
	
	if(Ttype == 31){
		p->x[1] = p->x[0];
		p->y[1] = p->y[0] + 1;
		p->x[2] = p->x[1];
		p->y[2] = p->y[1] + 1;
		p->x[3] = p->x[2];
		p->y[3] = p->y[2] + 1;
		p->flag = 31;
	}
}

/*
direction = 0 顺时针
direction = 1 逆时针 
*/
void rotateTetris(Tetris * p, int direction){
	
	if(p->flag == 20){
		p->x[0] = p->x[0] + 1;
		p->y[0] = p->y[0] + 1;
		p->x[1] = p->x[0] + 1;
		p->y[1] = p->y[0] - 1;
		p->x[2] = p->x[0] + 1;
		p->y[2] = p->y[0];
		p->x[3] = p->x[0];
		p->y[3] = p->y[0] + 1;
		p->flag = 21;
		return;
	}
	
	if(p->flag == 21){
		if(p->x[0] > 2){
			generateTetris(p, 20, p->x[0] - 1, p->y[0] - 1);
		}
		return;
	}
	
	if(p->flag == 30){
		if(a[p->x[1]][p->y[1] + 1] == 0 && a[p->x[1]][p->y[1] + 2] == 0){
			p->x[0] = p->x[0] + 1;
			p->y[0] = p->y[0] - 1;
			p->x[1] = p->x[0];
			p->y[1] = p->y[0] + 1;
			p->x[2] = p->x[0];
			p->y[2] = p->y[1] + 1;
			p->x[3] = p->x[0];
			p->y[3] = p->y[2] + 1;
			p->flag = 31;
		}
		return;
	}
	
	if(p->flag == 31){
		if(p->x[0] > 1 && p->x[0] + 2 <= AX - 1){
			generateTetris(p, 30, p->x[0] - 1, p->y[0] + 1);
		}
		return;
	}
}

int couldDownBlock(int x, int y){
	int i;
	int rlt = 1;
	if(a[x][y + 1] == 1){
		rlt = 0;
	}
	return rlt;	
}

//判断是否可以下落, 可以返回1， 否则返回0 
int couldDown(const Tetris * p){
	int i;
	
	//触底 
	if (p->y[3] > AY - 2){
		return 0;
	}
	
	if(p-> flag == 1 || p ->flag == 21){
		int t1 = couldDownBlock(p->x[2], p->y[2]);
		int t2 = couldDownBlock(p->x[3], p->y[3]);
		return t1 && t2;
	}
	
	if(p->flag == 20){
		int t0 = couldDownBlock(p->x[0], p->y[0]);
		int t2 = couldDownBlock(p->x[2], p->y[2]);
		int t3 = couldDownBlock(p->x[3], p->y[3]);	
		return t0 && t2 && t3;
	}
	
	if(p-> flag == 30){
		int t0 = couldDownBlock(p->x[0], p->y[0]);
		int t1 = couldDownBlock(p->x[1], p->y[1]);
		int t2 = couldDownBlock(p->x[2], p->y[2]);
		int t3 = couldDownBlock(p->x[3], p->y[3]);
		return t0 && t1 && t2 && t3;
	}
	
	if(p->flag == 31){
		return couldDownBlock(p->x[3], p->y[3]);
	}
	
	return 0;	 
}

//void clearBoard(const Tetris * p){
//	int i, j, k;
//	for(i = 0; i < 4; i++){
//		for(j = 0; j < BLOCK; j++){
//			for(k = 0; k < BLOCK; k++){
//				gotoxy(p->x[i] + j + FrameX, p->y[i] + k + FrameY);
//				printf(" ");
//			}
//		}
//	}
//}

void clearLine(){
	int i, j, k;
	int rlt;
	for(j = AY - 1; j > 1; j--){
		rlt = 1;
		for(i = 1; i < AX; i++){
			rlt = rlt && a[i][j];
		}	
		if(rlt){
//			gotoxy(50, 50);
//			printf("need to clear");
			for(k = j; k > 1; k--){
				for(i = 1; i < AX; i++){
					a[i][k] = a[i][k - 1];
				}
			}
			j++;
		}
	}	
} 
int randomFlag(){
	int a = rand() % 3 + 1;
	if(a == 1){
		return 1;
	}
	else{
		int b = rand() % 2;
		return a*10 + b; 
	}	
}

//
void gameOver(const Tetris * p){
	if(p->y[3] <= 2){
		gotoxy(FrameX, FrameY - 1);
		printf("Game Over!!!");
		int m, n;
		for(m = 1; m < AX; m++){
			for(n = 1; n < AY; n++){
				a[m][n] = 0;
			}
		}
		system("pause");
	}
		
}

void printScore(){
	gotoxy(FrameX + FRAME_width + 3, FrameY);
	printf("score: %d", score);
}

void playGame(){
	
	Tetris t;
	while(1){
		printScore();
		generateTetris(&t, randomFlag(), START_OFFSET_X, START_OFFSET_Y);
		//rotateTetris(&t, 0);
		setBoard(&t, 1);
		printBoard();
		int tempx, tempy, flag;
	
		while(1){
			tempx = t.x[0];
			tempy = t.y[0];
			flag = t.flag;
			sleep(1);
			if(kbhit()){
				int ch = getch();
				if(ch == 75){  // <-, 左移 
					if(t.x[0] > 1){
						//clearBoard(&t);
						setBoard(&t, 0);
						tempx -= 1;
						generateTetris(&t, flag, tempx, tempy);
						setBoard(&t, 1);
						printBoard();
					} 
				}
				
				if(ch == 77){  // ->, 右移 
					if(t.x[3] <= AX - 2 && t.x[2] <= AX - 2){
						//clearBoard(&t);
						setBoard(&t, 0);
						tempx += 1;
						generateTetris(&t, flag, tempx, tempy);
						setBoard(&t, 1);
						printBoard();
					}
				}
				
				if(ch == 80){ //下箭头， 顺时针旋转
					//clearBoard(&t);
					setBoard(&t, 0);					
					rotateTetris(&t, 0); 
					tempx = t.x[0];
					tempy = t.y[0];
					flag = t.flag;  
					setBoard(&t, 1);
					printBoard();
				}
			}

			if(couldDown(&t)){
				//clearBoard(&t);
				setBoard(&t, 0);
				generateTetris(&t, flag, tempx, tempy + 1);
				setBoard(&t, 1);
				printBoard();
			}
			else{
				//printScore();
//				gotoxy(0,50);
//				int m, n;
//				for(m = 1; m < AX; m++){
//					for(n = 1; n < AY; n++){
//						printf("%d ", a[m][n]);
//					}
//					printf("\n");
//				}
				gameOver(&t);
				score++;
				clearLine();
				printBoard();
				break;
			}		
		}
	}
}

int main(int argc, char *argv[]) {
	gotoxy(10, 3);
	printf("Rabih Younes大魔王");
	DrawGameFrame();
//	Tetris t;
//	generateTetris(&t, 1, START_OFFSET_X , 1);
//	setBoard(&t, 1);
//	printBoard();
	playGame();
	gotoxy(30, 40);
	return 0;
}
