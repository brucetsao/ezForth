// 2008/10/31           Wesley �W�[ LPC2210.c Timer0_isr() LED_change�P�_ 
// 2008/10/31           Lee �W�[ SelfTest.cpp test_mode() ������� 
// 2008/11/1 pm1:27     Wesly �W�[ E-Block �T�ӤJ�f��� 
//                              0x80010001  self_test_entry()  
//                              0x8001000d  UART_pro_entry()
//                              0x80010019  time_entry()
// 2008/11/1 pm1:39    Wesley Note: LPC2210.c  Timer0_isr �P  lpc2xxx_cstartup_Jmp2IRQ.s f FIQ ��m���@�P  
//                              0x40000218  Timer0_isr (IAR �ثe�L�k�s��,����ʽT�{)             
// 2008/11/1 pm4:19    Wesley �ק� char Warning 
// 2008/11/3 pm3:39    Wesley Open JTAG debug RTCLK  
// 2008/11/03 pm6:06    Wesley Set upgrade.cpp To @"UpgradeROM" 
// 2008/11/04          1.�ק�RTC�u���w��Check
//                     2.�ק�Upgrade�u���\�J�i�J�{��// 
// 2008/11/12 pm1:36   BZTM ok 

// 2008/11/13 pm3:45   BZTY=9 ok  
// 2008/12/08 am10:48  Latch ��P2.21�אּ P2.22 
// 2008/12/08 15:14    P0.24 �ì�low(LRCM Power Ctl)  
// 2008/12/09 am11:50  Hold Time�Ӫ��������L�k�ߧY����,�ק�Delay���
// 2008/12/09 am11:50  �Q�r�G�Q�r�q�Ϊ����q1.0�}�l 
// 2008/12/19 pm18:05  �ק� �Ĥ@�q�O�Эp�{����~  delete_node1
// 2009/01/08 pm4:27  �W�[ 2000~2099�~�|�~����
// 2009/01/08 pm4:43  �W�[ LED_ON_flag ���� ; LED_ON_flag=0 close LED&Buzzer!?
// 2009/01/20 pm5:31  �W�[ const MarkStrBoot ���N ��� Define Mark 
// 2009/02/02 pm5:08  �ק� LED_change,msTi,RecProcessing �� volatile
// 2009/02/09 pm1:46  �D�u�� mdy_bits() ; �ư� ����Ҧ�-�r�����{�H
// 2009/02/09 pm5:38  SoftWare Reset OK
// 2009/03/13 pm4:26  �ɱ� GALEDCLRDY nml_timer 
// 2009/03/16 pm4:26  �D�u��  Flash �S�� ; �ư� ���flash�Ҧ�-�r�����{�H
// 2009/03/17 pm12:54 ��time_entry()�� HardWare_1sec.c
#define  _HardWare 
//#define BCB_New_Version