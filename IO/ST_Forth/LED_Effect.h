//***�e�\��************************
void scroll_left(void);  //�V�����J
void scroll_leftB(void);  //Binary �V�����J
void scroll_leftX(int len); //�V�����J1
void scroll_right(void); //�V�k���J
void scroll_up(void);    //�V�W���J
void scroll_down(void);  //�V�U���J
void animate(void);      //�ʵe�a�J
void shot_left(int page_num);    //�g�J
void Vrain_down(void);   //�U�B
void Snow(void);         //����
void jmp_right(int page_num);    //���J
void over_down(void);    //�л\�V�U
void over_right(void);   //�л\�V�k
void appear(void);       //�ߧY��{
void appearRight(void);
//*********************************

//***��\��************************
void flash_Out(void);      //�ϥհ{�{
void Vrain_down_Out(void); //�]�o
void Snow_Out(void);       //�G�k
void animate_Out(void);    //�ʵe�a�X
void jmp_right_Out(int page_num);  //���X
void over_down_Out(void);  //�л\�V�U��\��
void over_right_Out(void);     //�л\�V�k��\��
void scroll_left_Out(void);  //�V�����X
void scroll_right_Out(void); //�V�k���X
void scroll_up_Out(void);    //�V�W���X
void scroll_down_Out(void);  //�V�U���X
void flash_NormalOut(void);  //�{�{
void disappear(void); //�ߧY����

#ifdef _HardWare
#else //BC6
void scroll_left_str(int page_num);
#endif

void jmp_right_Out_str(void); //�r����X
//*********************************