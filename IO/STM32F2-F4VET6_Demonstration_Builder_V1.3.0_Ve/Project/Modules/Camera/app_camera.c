/**
  ******************************************************************************
  * @file    app_camera.c
  * @author  MCD Application Team
  * @version V1.3.0
  * @date    14-January-2013
  * @brief   This file contains the camera capture functionality
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; COPYRIGHT 2013 STMicroelectronics</center></h2>
  *
  * Licensed under MCD-ST Liberty SW License Agreement V2, (the "License");
  * You may not use this file except in compliance with the License.
  * You may obtain a copy of the License at:
  *
  *        http://www.st.com/software_license_agreement_liberty_v2
  *
  * Unless required by applicable law or agreed to in writing, software 
  * distributed under the License is distributed on an "AS IS" BASIS, 
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  *
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "mod_calendar.h"
#include "app_camera.h"
#include "libjpeg_utils.h"

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
InParams_Typedef  jpeg_params; 

const uint8_t ImageHeader_QQVGA24Bit[RGB_HEADER_SIZE] =
  {
    0x42, 0x4D,              /* Offet0: BMP Magic Number */
    0x36, 0x84, 0x03, 0x00,  /* Offset2 : filesz : Size of the BMP file 240*320*3 + 54 */
    0x00, 0x00, 0x00, 0x00,  /* Offset6, Offset8 : Reserved0, Reserved1 =0 */
    0x36, 0x00, 0x00, 0x00,  /* Offset10 : bmp_offset: Offset of bitmap data (pixels)  = 54 = 0x36 */
    0x28, 0x00, 0x00, 0x00,  /* Offset14 : header_sz : The number of bytes in the header (from this point). */
    0x40, 0x01, 0x00, 0x00,  /* Offset18 : width 320 */
    0xF0, 0x00, 0x00, 0x00,  /* Offset2 : height 240 */
    0x01, 0x00,              /* Offset26 : nplanes */
    0x18, 0x00,              /* Offset24: Bits per Pixels */
    0x00, 0x00, 0x00, 0x00,  /* Offset30: compress_type = 0  */
    0x00, 0x58, 0x02, 0x00,  /* Offset34 : bmp bytes size*/
    0x00, 0x00, 0x00, 0x00,  /* Offset38 : X Resolution : Pixel per meters = 0 */
    0x00, 0x00, 0x00, 0x00,  /* Offset42 : Y Resolution : Pixel per meters */
    0x00, 0x00, 0x00, 0x00,  /* Offset46 : Number of Colours = 0 */
    0x00, 0x00, 0x00, 0x00,  /* Offset50 : Important Colours = 0 */
  };

ImageBuffer_TypeDef ImageBuffer =
  {
    RGB_HEADER_SIZE,
    (uint8_t*)ImageHeader_QQVGA24Bit,
    (uint32_t)IMAGE_BUFFER_SIZE,
    (uint8_t*)FSMC_SRAM_ADDRESS,
    (uint8_t*)(FSMC_SRAM_ADDRESS  + MAX_IMAGE_SIZE),
    (uint8_t*)(FSMC_SRAM_ADDRESS + 3 * MAX_IMAGE_SIZE),
    {0},
  };
extern Camera_TypeDef Camera;
static uint32_t RecoveryImageCounter = 0;



/* Private function prototypes -----------------------------------------------*/
static void RGB16toRGB24(uint8_t *pDestBuffer, uint8_t *pSrcBuffer, uint8_t is_bgr);
static uint8_t Save_Bmp_To_File (uint8_t *path , uint8_t *file_name);
static uint8_t Save_Jpg_To_File (uint8_t *path , uint8_t *file_name);
/* Private functions ---------------------------------------------------------*/

/**
  * @brief  Save the image frame into a file
  * @param  Storage path
  * @retval File name
  */
uint8_t Save_Image_To_File (uint8_t *path , uint8_t *file_name, uint8_t image_format)
{
 if(image_format == 0)
 {
   return Save_Bmp_To_File (path , file_name);
 }
 else
 {
    return Save_Jpg_To_File (path , file_name);
 }
}


/**
  * @brief  Save the image frame into a file
  * @param  Storage path
  * @param  file_name 
  * @retval Status 0 = Sucess, !0 :error
  */
static uint8_t Save_Bmp_To_File (uint8_t *path , uint8_t *file_name)
{
  RTC_TimeTypeDef   RTC_TimeStructure;
  RTC_DateTypeDef   RTC_DateStructure;
  uint32_t i = 0 ,j = 0 , Index;

  FIL file;

  for ( i = 0 ; i < IMAGE_COLUMN_SIZE; i++)
  {
    for ( j= 0 ; j < 2 * IMAGE_LINE_SIZE; j++)
    {
      ImageBuffer.SrcData[j + (2 * IMAGE_LINE_SIZE * i)] = ImageBuffer.RawData[j + (2 * IMAGE_LINE_SIZE * ( IMAGE_COLUMN_SIZE- 1 - i))];
    }
  }


  /* Convert RGB16 image to RGB24 */
  RGB16toRGB24(ImageBuffer.DestData, ImageBuffer.SrcData, 1);

  /* Update file name */
  strcpy((char *)ImageBuffer.ImageName , (char *)path),
  strcat ((char *)ImageBuffer.ImageName, "/");

  if ( RTC_Error == 0)
  {
    RTC_GetTime(RTC_Format_BIN, &RTC_TimeStructure);
    RTC_GetDate(RTC_Format_BIN, &RTC_DateStructure);

    sprintf((char *)file_name, "Camera_%02d%02d%d%02d%02d%02d.bmp", RTC_DateStructure.RTC_Date,
            RTC_DateStructure.RTC_Month,
            RTC_DateStructure.RTC_Year + 2000,
            RTC_TimeStructure.RTC_Hours,
            RTC_TimeStructure.RTC_Minutes,
            RTC_TimeStructure.RTC_Seconds);
  }
  else
  {
    /* Wait until one RNG number is ready */
    while(RNG_GetFlagStatus(RNG_FLAG_DRDY)== RESET)
    {
    }
    RecoveryImageCounter = (uint32_t )(RNG_GetRandomNumber() & 0x7FFFFFFF) ;
    sprintf((char *)file_name, "Camera_%014d.bmp", (int)RecoveryImageCounter);
  }

  strcat ((char *)ImageBuffer.ImageName, (char *)file_name);


  /* Can not create file */
  if (f_open(&file, (char *)ImageBuffer.ImageName, FA_CREATE_NEW | FA_WRITE) != FR_OK)
  {
    return 0;
  }

  /* Write the received data into the file */
  if (f_write(&file, (char*)ImageBuffer.ImageHeader, RGB_HEADER_SIZE, (UINT*)&Index))
  {
    f_close(&file);
    return 0;
  }

  if (f_write(&file, (char*)ImageBuffer.DestData, MAX_IMAGE_SIZE, (UINT*)&Index))
  {
    f_close(&file);
    return 0;
  }
  /* Close file */
  f_close(&file);
  return 1 ;
}
/**
  * @brief  Convert RGB16 image to RGB24.
  * @param  pDestBuffer: buffer hold the data in RGB24 format
  * @param  pSrcBuffer: buffer hold the data in RGB16 format
  * @param  is_bgr: 1 if bgr coding is used, 1 if rgb (inverted)      
  * @retval None
  */
static void RGB16toRGB24(uint8_t *pDestBuffer, uint8_t *pSrcBuffer, uint8_t is_bgr)
{
  uint16_t *pSrc;
  uint8_t *pDest;
  uint32_t i = 0, j = 0;
  uint16_t value;

  pSrc = (uint16_t*) & pSrcBuffer[IMAGE_BUFFER_SIZE] - 1 ;
  pDest = (uint8_t*) & pDestBuffer[MAX_IMAGE_SIZE];

  for (i = IMAGE_COLUMN_SIZE; i > 0; i-- )
  {
    pDest -= (3 * IMAGE_LINE_SIZE);

    for (j = 2 * IMAGE_LINE_SIZE; j > 0; j -= 2 )
    {
      value    = (uint16_t) * pSrc;

      if( is_bgr)
      {
        *pDest++ = BMP_PIXEL16_TO_B(value);
        *pDest++ = BMP_PIXEL16_TO_G(value);
        *pDest++ = BMP_PIXEL16_TO_R(value);
      }
      else
      {
        *pDest++   = BMP_PIXEL16_TO_R(value);
        *pDest++   = BMP_PIXEL16_TO_G(value);
        *pDest++   = BMP_PIXEL16_TO_B(value);
      }
      pSrc--;
    }
    pDest -= (3 * IMAGE_LINE_SIZE );
  }
}

/**
  * @brief  Apply camera native effects
  * @param  ieffect : effect index
  * @retval None
  */ 
void Apply_camera_native_effects (uint8_t ieffect)
{
  if( Camera == OV2640_CAMERA)
  {
    switch (ieffect )
    {
    case 1 : //Normal
        /* Do Nothing */
      break;

    case 2 : //Antique
         OV2640_ColorEffectsConfig(0x40, 0xa6);
      break;

    case 3 : //Bluish
         OV2640_ColorEffectsConfig(0xa0, 0x40);
      break;

    case 4 : //Greenish
         OV2640_ColorEffectsConfig(0x40, 0x40);
      break;

    case 5 : //reddish
         OV2640_ColorEffectsConfig(0x40, 0xc0);
      break;

    case 6 : //Black & White
         OV2640_BandWConfig(0x18);
      break;

    case 7 : //Negative
         OV2640_BandWConfig(0x40);
      break;

    case 8 : //Negative B&W
         OV2640_BandWConfig(0x58);
      break;

    default:
      break;
    }
  }
}

/**
  * @brief  Save the image frame into a file
  * @param  Storage path
  * @param  file_name: Jpeg file name
  * @retval Status 
  */
static uint8_t Save_Jpg_To_File (uint8_t *path , uint8_t *file_name)
{
  RTC_TimeTypeDef   RTC_TimeStructure;
  RTC_DateTypeDef   RTC_DateStructure;
  FIL file;

  /* Update file name */
  strcpy((char *)ImageBuffer.ImageName , (char *)path),
  strcat ((char *)ImageBuffer.ImageName, "/");

  if ( RTC_Error == 0)
  {
    RTC_GetTime(RTC_Format_BIN, &RTC_TimeStructure);
    RTC_GetDate(RTC_Format_BIN, &RTC_DateStructure);

    sprintf((char *)file_name, "Camera_%02d%02d%d%02d%02d%02d.jpg", RTC_DateStructure.RTC_Date,
            RTC_DateStructure.RTC_Month,
            RTC_DateStructure.RTC_Year + 2000,
            RTC_TimeStructure.RTC_Hours,
            RTC_TimeStructure.RTC_Minutes,
            RTC_TimeStructure.RTC_Seconds);
  }
  else
  {
    sprintf((char *)file_name, "Camera_%08d.jpg", (int)(RecoveryImageCounter++));
  }

  strcat ((char *)ImageBuffer.ImageName, (char *)file_name);
  /* Can not create file */
  if (f_open(&file, (char *)ImageBuffer.ImageName, FA_CREATE_NEW | FA_WRITE) != FR_OK)
  {
    return 0;
  }

  /* Convert RGB16 image to RGB24 */
  RGB16toRGB24(ImageBuffer.DestData, ImageBuffer.RawData , 1);

  /* Set compression parameters */

  jpeg_params.in_buff = (uint8_t *)ImageBuffer.DestData;
  jpeg_params.in_length = IMAGE_COLUMN_SIZE * IMAGE_LINE_SIZE * 3;
  jpeg_params.in_width = IMAGE_LINE_SIZE;
  jpeg_params.in_height = IMAGE_COLUMN_SIZE;
  jpeg_params.in_bpp = 3;
  jpeg_params.in_colorspace = JCS_RGB;
  jpeg_params.in_imagequality = 100;

  jpeg_compress(&file, &jpeg_params);

  /* Close file */
  f_close(&file);
  return 1 ;
}
/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
