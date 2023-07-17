# bypass-iap-ios

Script desenvolvido para o artigo "Where Is My Money? An Analysis of Vulnerable In-app Purchases in iOS Apps". O código desse repositório testa vulnerabilidades em qualquer aplicativo disponível na App Store desde que sigam-se os passos abaixo para o setup inicial. 

Este código foi desenvolvido para fins didáticos e científicos. Não use esse código para causar danos a outras pessoas ou instituições. O uso indiscriminado desse material não é minha responsabilidade. Veja a [Disclaimer of Damages](##-Disclaimer-of-Damages) para mais detalhes.

## Material necessário
* 1 iPhone com jailbreak com acesso via SSH
* Um computador. O computador deve conter:
	* Acesso via SSH ([iPhoneTunnel](https://code.google.com/archive/p/iphonetunnel-mac/downloads), [iProxe](https://command-not-found.com/iproxy), etc.)
	* Sistema de build [Theos](https://theos.dev/) instalado

## Passo a passo
1. Estabeleça uma conexão SSH entre o computador e o seu iPhone
2. Baixe o aplicativo que você quer testar normalmente via App Store
3. Verifique o arquivo Makefile e garanta que as variáveis THEOS_DEVICE_IP e THEOS_DEVICE_PORT estão corretas para o seu iPhone
4. Verifique o arquivo bypassIAPiOS.plist e certifique-se que o bundle id do aplicativo alvo esteja listado
5. Build e instale o script no seu iPhone com `make package install`

! Você pode verificar os logs usando o app Console no seu MacOS para identificar novas keys vulneráveis e atualizar o script. Tenha em mente que o uso do app Console afeta o desempenho do seu iPhone.

! Todas as modificações no script devem ser realizadas no arquivo Tweak.x

## Citação
Adicionar bibitex do artigo aqui

## Disclaimer of Damages
Use of this script is at all times "at your own risk". If you are dissatisfied with any aspect of any of these terms and conditions or any other policies, your sole remedy is to discontinue use of the material. In no event will I or any contributors be liable to any user or third party for any damages resulting from the use or inability to use this material, whether based on warranty, contract, tort, or any other legal theory, and whether the site is or not advised of the possibility of such damages. I accept no responsibility for any loss, damage or liability arising out of or in connection with this material. In no event will I be liable for any indirect, special, punitive, exemplary, incidental or consequential damages. This limitation will apply whether or not the other party has been advised of the possibility of such damages.
