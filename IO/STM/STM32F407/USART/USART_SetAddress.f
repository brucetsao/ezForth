void USART_SetAddress(USART_TypeDef* USARTx, uint8_t USART_Address)
{
  /* Check the parameters */
  assert_param(IS_USART_ALL_PERIPH(USARTx));
  assert_param(IS_USART_ADDRESS(USART_Address)); 
    
  /* Clear the USART address */
  USARTx->CR2 &= (uint16_t)~((uint16_t)USART_CR2_ADD);
  /* Set the USART address node */
  USARTx->CR2 |= USART_Address;
}