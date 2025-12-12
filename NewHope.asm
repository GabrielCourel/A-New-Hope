jmp init

Msn0: string "mais um imperial explode!!"
Msn1: string "quer jogar novamente? <s/n>"
Msn2: string "a rebeliao foi derrotada"
Msn3: string "um grande triunfo para os rebeldes!"

Letra: var #1		; Contem a letra que foi digitada

posNave: var #1			; Contem a posicao atual da Nave
posAntNave: var #1		; Contem a posicao anterior da Nave
dirTiroNave: var #1     ; Contem a direcao do tiro
nVidasNave: var #1		; Contem a quantidade de vidas restantes da Nave
posAlien: var #1		; Contem a posicao atual do Alien
posAntAlien: var #1		; Contem a posicao anterior do Alien
dirTiroAlien: var #1     ; Contem a direcao do tiro
nVidasAlien: var #1		; Contem a quantidade de vidas restantes do Alien

posTiroNave: var #1			; Contem a posicao atual do Tiro
posAntTiroNave: var #1		; Contem a posicao anterior do Tiro
FlagTiroNave: var #1		; Flag para ver se Atirou ou nao (Barra de Espaco!!)

tempoTiroAlien: var #1		; Contem tempo em que o proximo tiro vai disparar
tempo: var #1		; Contador de tempo 
posTiroAlien: var #1		; Contem a posicao atual do Tiro
posAntTiroAlien: var #1		; Contem a posicao anterior do Tiro
FlagTiroAlien: var #1		; Flag para ver se Atirou ou nao

FlagJogando: var #1         ; Flag pra ver se esta jogando ou perdeu
nFase: var #1				; Contem numero da fase atual

PtrMapaAtual: var #1		;vai guardar o endereço das fases

IncRand: var #1			; Incremento para circular na Tabela de nr. Randomicos
Rand : var #30			; Tabela de nr. Randomicos entre 0 - 7
	static Rand + #0, #0
	static Rand + #1, #3
	static Rand + #2, #7
	static Rand + #3, #1
	static Rand + #4, #6
	static Rand + #5, #2
	static Rand + #6, #7
	static Rand + #7, #2
	static Rand + #8, #0
	static Rand + #9, #5
	static Rand + #10, #7
	static Rand + #11, #2
	static Rand + #12, #0
	static Rand + #13, #2
	static Rand + #14, #7
	static Rand + #15, #5
	static Rand + #16, #0
	static Rand + #17, #6
	static Rand + #18, #7
	static Rand + #19, #2
	static Rand + #20, #0
	static Rand + #20, #7
	static Rand + #21, #1
	static Rand + #22, #5
	static Rand + #23, #3
	static Rand + #24, #6
	static Rand + #25, #7
	static Rand + #26, #0
	static Rand + #27, #3
	static Rand + #28, #1
	static Rand + #29, #1

init:
	Loadn R1, #3
	store nVidasNave, R1

	Loadn R0, #1			; Contador para os Mods	= 0
	store nFase, R0


;Codigo principal
main:
	call ApagaTela
	
	call GerenciaFases
    
	loadn R1, #tela2Linha0	; Endereco onde comeca a primeira linha do cenario!!
	loadn R2, #512  			; cor branca!
	call ImprimeTela2   		;  Rotina de Impresao de Cenario na Tela Inteira
    
	loadn R1, #tela3Linha0	; Endereco onde comeca a primeira linha do cenario!!
	loadn R2, #2816   			; cor branca!
	call ImprimeTela2   		;  Rotina de Impresao de Cenario na Tela Inteira

	Loadn R0, #980			
	store posNave, R0		; Zera Posicao Atual da Nave
	store posAntNave, R0	; Zera Posicao Anterior da Nave
	
	store FlagTiroNave, R0		; Zera o Flag para marcar que ainda nao Atirou!
	store posTiroNave, R0		; Zera Posicao Atual do Tiro
	store posAntTiroNave, R0	; Zera Posicao Anterior do Tiro
	
	Loadn R0, #620
	store posAlien, R0		; Zera Posicao Atual do Alien
	store posAntAlien, R0	; Zera Posicao Anterior do Alien
		
	store FlagTiroAlien, R0		; Zera o Flag para marcar que ainda nao Atirou!
	store posTiroAlien, R0		; Zera Posicao Atual do Tiro
	store posAntTiroAlien, R0	; Zera Posicao Anterior do Tiro
	
	Loadn R1, #0
	store dirTiroAlien, R1
	
	call ImprimeUI
	
	loadn r1, #3
	load r2, nFase
	mod r2, r2, r1
	loadn r1, #0
	cmp r2, r1
	jne Salva_VidasAlien
	loadn r2, #3
	Salva_VidasAlien:
	store nVidasAlien, r2
	
	call SorteiaTempoTiroAlien
		
	Loadn R0, #0			; Contador para os Mods	= 0
	loadn R2, #0			; Para verificar se (mod(c/10)==0
	store FlagJogando, R0
	store dirTiroNave, R0
	
	Loop:
	
		loadn R1, #10
		mod R1, R0, R1
		cmp R1, R2		; if (mod(c/10)==0
		ceq MoveNave	; Chama Rotina de movimentacao da Nave
	
		loadn R1, #30
		mod R1, R0, R1
		cmp R1, R2		; if (mod(c/30)==0
		ceq MoveAlien	; Chama Rotina de movimentacao do Alien
	
		loadn R1, #2
		mod R1, R0, R1
		cmp R1, R2		; if (mod(c/2)==0
		ceq MoveTiro	; Chama Rotina de movimentacao do Tiro
		ceq MoveTiroAlien	; Chama Rotina de movimentacao do Tiro do alien
	
		call Delay
		inc R0 	;c++
		
		jmp Loop
	
;Funcoes
;--------------------------

MoveNave:
	push r0
	push r1
	
	call MoveNave_RecalculaPos		; Recalcula Posicao da Nave

; So' Apaga e Redezenha se (pos != posAnt)
;	If (posNave != posAntNave)	{	
	load r0, posNave
	load r1, posAntNave
	cmp r0, r1
	jeq MoveNave_Skip
		call MoveNave_Apaga
		call MoveNave_Desenha		;}
  MoveNave_Skip:
	
	pop r1
	pop r0
	rts

;--------------------------------
	
MoveNave_Apaga:		; Apaga a Nave preservando o Cenario!
	push R0
    push R1
    push R2
    push R3

    load R0, posAntNave    ; Pega a posição anterior da nave
    
    ; Recupera o mapa atual (Fase 1 ou 2) que salvamos
    load R1, PtrMapaAtual  
    
    ; Matemática Simples: Endereço do Mapa + Posição da Nave
    add R2, R1, R0         
    
    ; Lê o que está no mapa original (Fundo ou Parede)
    loadi R3, R2           
    
    ; Desenha na tela, restaurando o cenário perfeitamente
    outchar R3, R0         
    
    pop R3
    pop R2
    pop R1
    pop R0
    rts
;----------------------------------	
	
MoveNave_RecalculaPos:		; Recalcula posicao da Nave em funcao das Teclas pressionadas
	push R0
	push R1
	push R2
	push R3

	load R0, posNave
	
	inchar R1				; Le Teclado para controlar a Nave
	loadn R2, #'a'
	cmp R1, R2
	jeq MoveNave_RecalculaPos_A
	
	loadn R2, #'d'
	cmp R1, R2
	jeq MoveNave_RecalculaPos_D
		
	loadn R2, #'w'
	cmp R1, R2
	jeq MoveNave_RecalculaPos_W
		
	loadn R2, #'s'
	cmp R1, R2
	jeq MoveNave_RecalculaPos_S
	
	loadn R2, #' '
	cmp R1, R2
	jeq MoveNave_RecalculaPos_Tiro
	
	loadn R2, #'['
	cmp R1, R2
	jeq MoveNave_RecalculaDirEsq_Tiro
	
	loadn R2, #']'
	cmp R1, R2
	jeq MoveNave_RecalculaDirDir_Tiro
	
  MoveNave_RecalculaPos_Fim:	; Se nao for nenhuma tecla valida, vai embora
	store posNave, R0
	pop R3
	pop R2
	pop R1
	pop R0
	rts

  MoveNave_RecalculaPos_A:	; Move Nave para Esquerda
	loadn R1, #40
	loadn R2, #0
	mod R1, R0, R1		; Testa condicoes de Contorno 
	cmp R1, R2
	jeq MoveNave_RecalculaPos_Fim
	dec R0	; pos = pos -1
	jmp MoveNave_RecalculaPos_Fim
		
  MoveNave_RecalculaPos_D:	; Move Nave para Direita	
	loadn R1, #40
	loadn R2, #39
	mod R1, R0, R1		; Testa condicoes de Contorno 
	cmp R1, R2
	jeq MoveNave_RecalculaPos_Fim
	inc R0	; pos = pos + 1
	jmp MoveNave_RecalculaPos_Fim
	
  MoveNave_RecalculaPos_W:	; Move Nave para Cima
	loadn R1, #160
	loadn R2, #40
	cmp R0, R1		; Testa condicoes de Contorno 
	jle MoveNave_RecalculaPos_Fim
	sub R0, R0, R2	; pos = pos - 40
	jmp MoveNave_RecalculaPos_Fim

  MoveNave_RecalculaPos_S:	; Move Nave para Baixo
	loadn R1, #1159
	cmp R0, R1		; Testa condicoes de Contorno 
	jgr MoveNave_RecalculaPos_Fim
	loadn R1, #40
	add R0, R0, R1	; pos = pos + 40
	jmp MoveNave_RecalculaPos_Fim	
	
  MoveNave_RecalculaPos_Tiro:	
	loadn R1, #1			; Se Atirou:
	store FlagTiroNave, R1		; FlagTiroNave = 1
	store posTiroNave, R0		; posTiroNave = posNave
	jmp MoveNave_RecalculaPos_Fim	

  MoveNave_RecalculaDirEsq_Tiro:	
	load R1, dirTiroNave			; Diminui direcao do tiro da nave
	loadn R2, #0
	dec R1
	cmp R1, R2
	store dirTiroNave, R1		
	jeg MoveNave_RecalculaPos_Fim
	loadn R2, #3  				; Se for de 0 para -1 volta para 3
	store dirTiroNave, R2
	jmp MoveNave_RecalculaPos_Fim	
	
  MoveNave_RecalculaDirDir_Tiro:	
	load R1, dirTiroNave 		; Aumenta direcao do tiro da nave
	loadn R2, #4
	inc R1
	mod R1, R1, R2
	store dirTiroNave, R1		
	jmp MoveNave_RecalculaPos_Fim	
	
;----------------------------------
MoveNave_Desenha:	; Desenha caractere da Nave
	push R0
	push R1
	
	Loadn R1, #126	; Nave
	load R0, posNave
	outchar R1, R0
	store posAntNave, R0	; Atualiza Posicao Anterior da Nave = Posicao Atual
	
	pop R1
	pop R0
	rts

	
	
	

	
;----------------------------------
;----------------------------------
;----------------------------------

MoveAlien:
	push r0
	push r1
	
	call MoveAlien_RecalculaPos
	
; So' Apaga e Redezenha se (pos != posAnt)
;	If (pos != posAnt)	{	
	load r0, posAlien
	load r1, posAntAlien
	cmp r0, r1
	jeq MoveAlien_Skip
		call MoveAlien_Apaga
		call MoveAlien_Desenha		;}
  MoveAlien_Skip:
	
	pop r1
	pop r0
	rts
		
; ----------------------------
		
MoveAlien_Apaga:
	push R0
    push R1
    push R2
    push R3
    
    load R0, posAntAlien
    
    ; Primeiro, pega o caractere do cenário (Backup)
    load R1, PtrMapaAtual
    add R2, R1, R0
    loadi R3, R2
    
    ; Agora verifica colisão visual: O Alien estava em cima da Nave?
    load R1, posAntNave
    cmp R0, R1
    jne MoveAlien_Apaga_Fim
        loadn R3, #126      ; Se estava sobre a nave, desenha o X-Wing (Index 126)
        
MoveAlien_Apaga_Fim:
    outchar R3, R0
    
    pop R3
    pop R2
    pop R1
    pop R0
    rts
;----------------------------------	
; sorteia nr. randomico entre 0 - 7
;					switch rand
;						case 0 : posNova = posAnt -41
;						case 1 : posNova = posAnt -40
;						case 2 : posNova = posAnt -39
;						case 3 : posNova = posAnt -1
;						case 4 : posNova = posAnt +1
;						case 5 : posNova = posAnt +39
;						case 6 : posNova = posAnt +40
;						case 7 : posNova = posAnt +41
	
MoveAlien_RecalculaPos:
	push R0
	push R1
	push R2
	push R3

	load R0, posAlien

; sorteia nr. randomico entre 0 - 7
	loadn R2, #Rand 	; declara ponteiro para tabela rand na memoria!
	load R1, IncRand	; Pega Incremento da tabela Rand
	add r2, r2, r1		; Soma Incremento ao inicio da tabela Rand
						; R2 = Rand + IncRand
	loadi R3, R2 		; busca nr. randomico da memoria em R3
						; R3 = Rand(IncRand)
						
	inc r1				; Incremento ++
	loadn r2, #30
	cmp r1, r2			; Compara com o Final da Tabela e re-estarta em 0
	jne MoveAlien_RecalculaPos_Skip
		loadn r1, #0		; re-estarta a Tabela Rand em 0
  MoveAlien_RecalculaPos_Skip:
	store IncRand, r1	; Salva incremento ++


; Switch Rand (r3)
 ; Case 0 : tenta subir diagonal ( -41 )
    loadn r2, #0
    cmp r3, r2
    jne MoveAlien_RecalculaPos_Case1
    ; VERIFICAÇÃO DE TOPO
    loadn r2, #160          ; Limite superior (Linha 4)
    cmp r0, r2
    jle MoveAlien_RecalculaPos_FimSwitch ; Se já estiver no topo, não sobe
    loadn r1, #41
    sub r0, r0, r1
    jmp MoveAlien_RecalculaPos_FimSwitch

 ; Case 1 : tenta subir reto ( -40 )
   MoveAlien_RecalculaPos_Case1:
    loadn r2, #1
    cmp r3, r2
    jne MoveAlien_RecalculaPos_Case2
    ; VERIFICAÇÃO DE TOPO
    loadn r2, #160          ; Limite superior
    cmp r0, r2
    jle MoveAlien_RecalculaPos_FimSwitch
    loadn r1, #40
    sub r0, r0, r1
    jmp MoveAlien_RecalculaPos_FimSwitch

 ; Case 2 : tenta subir diagonal ( -39 )
   MoveAlien_RecalculaPos_Case2:
    loadn r2, #2
    cmp r3, r2
    jne MoveAlien_RecalculaPos_Case3
    ; VERIFICAÇÃO DE TOPO
    loadn r2, #160
    cmp r0, r2
    jle MoveAlien_RecalculaPos_FimSwitch
    loadn r1, #39
    sub r0, r0, r1
    jmp MoveAlien_RecalculaPos_FimSwitch

 ; Case 3 : posAlien = posAlien - 1
   MoveAlien_RecalculaPos_Case3:
	loadn r2, #3	; Se Rand = 3
	cmp r3, r2
	jne MoveAlien_RecalculaPos_Case4
	loadn r1, #1
	sub r0, r0, r1
	jmp MoveAlien_RecalculaPos_FimSwitch	; Break do Switch

 ; Case 4 : posAlien = posAlien + 1	
   MoveAlien_RecalculaPos_Case4:
	loadn r2, #4	; Se Rand = 4
	cmp r3, r2
	jne MoveAlien_RecalculaPos_Case5
	loadn r1, #1
	add r0, r0, r1
	jmp MoveAlien_RecalculaPos_FimSwitch	; Break do Switch

 ; Case 5 : tenta descer ( +39 )
   MoveAlien_RecalculaPos_Case5:
    loadn r2, #5
    cmp r3, r2
    jne MoveAlien_RecalculaPos_Case6
    ; VERIFICAÇÃO DE FUNDO
    loadn r2, #1120         ; Limite inferior (Linha 28)
    cmp r0, r2
    jgr MoveAlien_RecalculaPos_FimSwitch ; Se estiver muito embaixo, não desce
    loadn r1, #39
    add r0, r0, r1
    jmp MoveAlien_RecalculaPos_FimSwitch

 ; Case 6 : tenta descer reto ( +40 )
   MoveAlien_RecalculaPos_Case6:
    loadn r2, #6
    cmp r3, r2
    jne MoveAlien_RecalculaPos_Case7
    ; VERIFICAÇÃO DE FUNDO
    loadn r2, #1120
    cmp r0, r2
    jgr MoveAlien_RecalculaPos_FimSwitch
    loadn r1, #40
    add r0, r0, r1
    jmp MoveAlien_RecalculaPos_FimSwitch

 ; Case 7 : tenta descer diagonal ( +41 )
   MoveAlien_RecalculaPos_Case7:
    loadn r2, #7
    cmp r3, r2
    jne MoveAlien_RecalculaPos_FimSwitch
    ; VERIFICAÇÃO DE FUNDO
    loadn r2, #1120
    cmp r0, r2
    jgr MoveAlien_RecalculaPos_FimSwitch
    loadn r1, #41
    add r0, r0, r1
	;jmp MoveAlien_RecalculaPos_FimSwitch	; Break do Switch	

 ; Fim Switch:
  MoveAlien_RecalculaPos_FimSwitch:	
	store posAlien, R0	; Grava a posicao alterada na memoria
	pop R3
	pop R2
	pop R1
	pop R0
	rts


;----------------------------------
MoveAlien_Desenha:
	push R0
	push R1
	
	Loadn R1, #96	; Alien
	load R0, posAlien
	outchar R1, R0
	store posAntAlien, R0
	
	pop R1
	pop R0
	rts

;----------------------------------
;----------------------------------
;--------------------------

MoveTiro:
	push r0
	push r1
	
	call MoveTiro_RecalculaPos

; So' Apaga e Redezenha se (pos != posAnt)
;	If (pos != posAnt)	{	
	load r0, posTiroNave
	load r1, posAntTiroNave
	cmp r0, r1
	jeq MoveTiro_Skip
		call MoveTiro_Apaga
		call MoveTiro_Desenha		;}
  MoveTiro_Skip:
	
	pop r1
	pop r0
	rts

;-----------------------------
	
MoveTiro_Apaga:
	push R0
    push R1
    push R2
    push R3
    
    load R0, posAntTiroNave
    
    ; Calcula o caractere do mapa
    load R1, PtrMapaAtual
    add R2, R1, R0
    loadi R3, R2
    
    ; Verifica se estava em cima da Nave (para não apagar a nave se o tiro sair dela)
    load R1, posAntNave
    cmp R0, R1
    jne MoveTiro_Apaga_Fim
        loadn R3, #126  ; Restaura a Nave
        
MoveTiro_Apaga_Fim:
    outchar R3, R0
    pop R3
    pop R2
    pop R1
    pop R0
    rts
;----------------------------------	
	
	
; if TiroFlag = 1
;	posTiroNave++
;	
	
MoveTiro_RecalculaPos:
	push R0
	push R1
	push R2
	push R3
	
	load R1, FlagTiroNave	; Se Atirou, movimenta o tiro!
	loadn R2, #1
	cmp R1, R2			; If FlagTiroNave == 1  Movimenta o Tiro
	jne MoveTiro_RecalculaPos_Fim2	; Se nao vai embora!
	
	load R0, posTiroNave	; TEsta se o Tiro Pegou no Alien
	load R1, posAlien
	cmp R0, R1			; IF posTiroNave == posAlien  BOOM!!
	jeq MoveTiro_RecalculaPos_Boom
	
	
	
	loadn R1, #40		; Testa condicoes de Contorno 
	loadn R2, #39
	mod R1, R0, R1		
	cmp R1, R2			; Se tiro chegou no limite direito
	jeq MoveTiro_SaiDaTela
	
	loadn R2, #160	
	cmp R0, R2			; Se tiro chegou na primeira linha
	jle MoveTiro_SaiDaTela
	
	loadn R1, #40		; Testa condicoes de Contorno 
	loadn R2, #0
	mod R1, R0, R1		
	cmp R1, R2			; Se tiro chegou no limite esquerdo
	jeq MoveTiro_SaiDaTela
	
	loadn R2, #1159	
	cmp R0, R2			; Se tiro chegou na ultima linha
	jgr MoveTiro_SaiDaTela
	
	jmp MoveTiro_RecalculaPos_Fim
	
  MoveTiro_SaiDaTela:
	call MoveTiro_Apaga
	loadn R0, #0
	store FlagTiroNave, R0	; Zera FlagTiroNave
	store posTiroNave, R0	; Zera e iguala posTiroNave e posAntTiroNave
	store posAntTiroNave, R0
	jmp MoveTiro_RecalculaPos_Fim2	
	
  MoveTiro_RecalculaPos_Fim:
  	load R3, dirTiroNave
  	
  	loadn R1, #0
  	cmp R1, R3
  	jne MoveTiro_DirDir
	loadn R2, #40
	sub R0, R0, R2
	store posTiroNave, R0	
  	jmp MoveTiro_RecalculaPos_Fim2
	
	  MoveTiro_DirDir:
		loadn R1, #1
		cmp R1, R3
	  	jne MoveTiro_DirBaixo
		inc R0
		store posTiroNave, R0	
  		jmp MoveTiro_RecalculaPos_Fim2
		
	  MoveTiro_DirBaixo:
		loadn R1, #2
	  	cmp R1, R3
	  	jne MoveTiro_DirEsq
		loadn R2, #40
		add R0, R0, R2		
		store posTiroNave, R0	
  		jmp MoveTiro_RecalculaPos_Fim2
	  	
	  MoveTiro_DirEsq:
		loadn R1, #3
		cmp R1, R3
		dec R0	
		store posTiroNave, R0	
	
  MoveTiro_RecalculaPos_Fim2:
	pop R3
	pop R2
	pop R1
	pop R0
	rts

  MoveTiro_RecalculaPos_Boom:	
  	loadn R2, #0
  	load R3, nVidasAlien
  	dec R3
  	store nVidasAlien, R3
  	cmp R3, R2
  	jne MoveTiro_SaiDaTela
  	
  	load R2, nFase
	loadn r0, #9
	cmp r0, r2
	jeq Venceu
	
	; Limpa a Tela !!
  	loadn R1, #tela0Linha0	; Endereco onde comeca a primeira linha do cenario!!
	loadn R2, #0  			; cor branca!
	call ImprimeTela   		;  Rotina de Impresao de Cenario na Tela Inteira
  	call ImprimeUI
	;imprime Voce Venceu !!!
	loadn r0, #526
	loadn r1, #Msn0
	loadn r2, #0
	call ImprimeStr
	
	;imprime quer jogar novamente
	loadn r0, #605
	loadn r1, #Msn1
	loadn r2, #0
	call ImprimeStr
	
	MoveTiro_RecalculaPos_SouN:
	call DigLetra
	loadn r0, #'n'
	load r1, Letra
	cmp r0, r1				; tecla == 's' ?
	jeq MoveTiro_RecalculaPos_FimJogo	; tecla nao e' 's'
	loadn r0, #'s'
	cmp r0, r1
	jne MoveTiro_RecalculaPos_SouN	
	; Se quiser jogar novamente...
	
	load R2, nFase
	inc r2 ; incrementa a fase
	store nFase, r2
	
	call ApagaTela
	
	pop r2
	pop r1
	pop r0

	pop r0	; Da um Pop a mais para acertar o ponteiro da pilha, pois nao vai dar o RTS !!
	jmp main
	
  Venceu:
  	; Limpa a Tela !!
  	loadn R1, #tela0Linha0	; Endereco onde comeca a primeira linha do cenario!!
	loadn R2, #0  			; cor branca!
	call ImprimeTela   		;  Rotina de Impresao de Cenario na Tela Inteira
  	call ImprimeUI
	;imprime Voce Venceu !!!
	loadn r0, #523
	loadn r1, #Msn3
	loadn r2, #0
	call ImprimeStr
	halt

  MoveTiro_RecalculaPos_FimJogo:
	call ApagaTela
	halt

;----------------------------------
MoveTiro_Desenha:
	push R0
	push R1
	push R2
	
	load R2, dirTiroNave
	loadn R1, #2
	mod R1, R2, R1
	loadn R2, #0
	cmp R1, R2
	jne MoveTiro_DesenhaH
	
	Loadn R1, #58	; Tiro
	jmp MoveTiro_DesenhaFim

	MoveTiro_DesenhaH:
	Loadn R1, #45	; Tiro
	
	MoveTiro_DesenhaFim:
	load R0, posTiroNave
	outchar R1, R0
	store posAntTiroNave, R0
	
	pop R2
	pop R1
	pop R0
	rts

;----------------------------------

;----------------------------------
;----------------------------------
;--------------------------
SorteiaTempoTiroAlien:
; sorteia nr. randomico entre 0 - 7
	push R1 
	push R2
	push R3
	
	loadn R2, #Rand 	; declara ponteiro para tabela rand na memoria!
	load R1, IncRand	; Pega Incremento da tabela Rand
	add r2, r2, r1		; Soma Incremento ao inicio da tabela Rand
						; R2 = Rand + IncRand
	loadi R3, R2 		; busca nr. randomico da memoria em R3
						; R3 = Rand(IncRand)
						
	inc r1				; Incremento ++
	loadn r2, #30
	cmp r1, r2			; Compara com o Final da Tabela e re-estarta em 0
	jne SalvaTempo
		loadn r1, #0		; re-estarta a Tabela Rand em 0
	SalvaTempo:
	store IncRand, r1	; Salva incremento ++
	inc r3
	loadn r1, #50
	mul r3, r3, r1
	store tempoTiroAlien, r3
	
	pop R3
	pop R2
	pop R1
	rts

MoveTiroAlien:
	push r0
	push r1
	push r2
			
	load R1, tempoTiroAlien
	mod r0, r0, r1
	loadn r1, #0
	cmp R0, R1		; if mod(c,tempoTiroAlien)==0
	jne MoveTiroAlien_Continua
	
	loadn r1, #1
	store FlagTiroAlien, r1
	load r1, posAlien
	store posTiroAlien, r1
	store posAntTiroAlien, r1
	
	loadn r0, #3
	load r1, nFase
	dec r1
	div r1, r1, r0
	loadn r0, #2
	cmp r0, r1
	jeq Tiro_Dificil
	loadn r0, #1
	cmp r0, r1
	jeq Tiro_Medio
	
	;Tiro_facil:
	loadn r0, #4 ; Direcao aleatoria para o tiro
	load r1, dirTiroAlien
	inc r1
	mod r0, r1, r0 
	store dirTiroAlien, r0
	jmp Tiro_Selecionado
	
	Tiro_Medio:
	loadn r0, #4 ; Direcao aleatoria para o tiro
	load r1, posAlien
	mod r0, r1, r0 
	store dirTiroAlien, r0
	jmp Tiro_Selecionado
	
	Tiro_Dificil:
	load r0, posNave
	load r1, posAlien
	loadn r2, #40
	div r0, r0, r2
	div r1, r1, r2
	cmp r0, r1
	jeq Tiro_Dificil_DirEsq
	jeg Tiro_Dificil_Baixo
	
	loadn r0, #0 ; Direcao aleatoria para o tiro
	store dirTiroAlien, r0
	jmp Tiro_Selecionado
	
	Tiro_Dificil_Baixo:
	loadn r0, #2 ; Direcao aleatoria para o tiro
	store dirTiroAlien, r0
	jmp Tiro_Selecionado
	
	Tiro_Dificil_DirEsq:
	load r0, posNave
	load r1, posAlien
	cmp r0, r1
	jeg Tiro_Dificil_Dir
	loadn r0, #3 ; Direcao aleatoria para o tiro
	store dirTiroAlien, r0
	jmp Tiro_Selecionado
	
	Tiro_Dificil_Dir:
	loadn r0, #1 ; Direcao aleatoria para o tiro
	store dirTiroAlien, r0
	jmp Tiro_Selecionado
	
	Tiro_Selecionado:	
	call SorteiaTempoTiroAlien
	MoveTiroAlien_Continua:
	call MoveTiroAlien_RecalculaPos
	
; So' Apaga e Redezenha se (pos != posAnt)
;	If (pos != posAnt)	{	
	load r0, posTiroAlien
	load r1, posAntTiroAlien
	cmp r0, r1
	jeq MoveTiroAlien_Skip
		call MoveTiroAlien_Apaga
		call MoveTiroAlien_Desenha		;}
  MoveTiroAlien_Skip:
	pop r2
	pop r1
	pop r0
	rts

;-----------------------------
	
MoveTiroAlien_Apaga:
	push R0
    push R1
    push R2
    push R3
    
    load R0, posAntTiroAlien
    
    ; Calcula o caractere do mapa
    load R1, PtrMapaAtual
    add R2, R1, R0
    loadi R3, R2
    
    ; Verifica se estava em cima do Alien (para não apagar o Alien quando ele atira)
    load R1, posAntAlien
    cmp R0, R1
    jne MoveTiroAlien_Apaga_Fim
        loadn R3, #96   ; Restaura o Tie Fighter (Index 96)
        
MoveTiroAlien_Apaga_Fim:
    outchar R3, R0
    pop R3
    pop R2
    pop R1
    pop R0
    rts
;----------------------------------	
	
	
; if TiroFlag = 1
;	posTiroNave++
;	
	
MoveTiroAlien_RecalculaPos:
	push R0
	push R1
	push R2
	push R3
	
	load R1, FlagTiroAlien	; Se Atirou, movimenta o tiro!
	
	loadn R2, #1
	cmp R1, R2			; If FlagTiroNave == 1  Movimenta o Tiro
	jne MoveTiroAlien_RecalculaPos_Fim2	; Se nao vai embora!
	
	load R0, posTiroAlien	; TEsta se o Tiro Pegou na Nave
	load R1, posNave
	cmp R0, R1			; IF posTiroNave == posAlien  BOOM!!
	jeq MoveTiroAlien_RecalculaPos_Boom
	
	
	
	loadn R1, #40		; Testa condicoes de Contorno 
	loadn R2, #39
	mod R1, R0, R1		
	cmp R1, R2			; Se tiro chegou no limite direito
	jeq MoveTiroAlien_SaiDaTela
	
	loadn R2, #160	
	cmp R0, R2			; Se tiro chegou na primeira linha
	jle MoveTiroAlien_SaiDaTela
	
	loadn R1, #40		; Testa condicoes de Contorno 
	loadn R2, #0
	mod R1, R0, R1		
	cmp R1, R2			; Se tiro chegou no limite esquerdo
	jeq MoveTiroAlien_SaiDaTela
	
	loadn R2, #1159	
	cmp R0, R2			; Se tiro chegou na ultima linha
	jgr MoveTiroAlien_SaiDaTela
	
	jmp MoveTiroAlien_RecalculaPos_Fim
	
  MoveTiroAlien_SaiDaTela:
	call MoveTiroAlien_Apaga
	loadn R0, #0
	store FlagTiroAlien, R0	; Zera FlagTiroNave
	store posTiroAlien, R0	; Zera e iguala posTiroNave e posAntTiroNave
	store posAntTiroAlien, R0
	jmp MoveTiroAlien_RecalculaPos_Fim2	
	
  MoveTiroAlien_RecalculaPos_Fim:
  	load R3, dirTiroAlien
  	
  	loadn R1, #0
  	cmp R1, R3
  	jne MoveTiroAlien_DirDir
	loadn R2, #40
	sub R0, R0, R2
	store posTiroAlien, R0	
  	jmp MoveTiroAlien_RecalculaPos_Fim2
	
	  MoveTiroAlien_DirDir:
		loadn R1, #1
		cmp R1, R3
	  	jne MoveTiroAlien_DirBaixo
		inc R0
		store posTiroAlien, R0	
  		jmp MoveTiroAlien_RecalculaPos_Fim2
		
	  MoveTiroAlien_DirBaixo:
		loadn R1, #2
	  	cmp R1, R3
	  	jne MoveTiroAlien_DirEsq
		loadn R2, #40
		add R0, R0, R2		
		store posTiroAlien, R0	
  		jmp MoveTiroAlien_RecalculaPos_Fim2
	  	
	  MoveTiroAlien_DirEsq:
		loadn R1, #3
		cmp R1, R3
		dec R0	
		store posTiroAlien, R0	
	
  MoveTiroAlien_RecalculaPos_Fim2:
	pop R3
	pop R2
	pop R1
	pop R0
	rts

  MoveTiroAlien_RecalculaPos_Boom:	
  	loadn R2, #0
  	load R3, nVidasNave
  	dec R3
  	store nVidasNave, R3
  	call ImprimeUI
  	cmp R3, R2
  	jne MoveTiroAlien_SaiDaTela
  	
	; Limpa a Tela !!
  	loadn R1, #tela0Linha0	; Endereco onde comeca a primeira linha do cenario!!
	loadn R2, #0  			; cor branca!
	call ImprimeTela   		;  Rotina de Impresao de Cenario na Tela Inteira
  	call ImprimeUI
	;imprime Voce perdeu !!!
	loadn r0, #526
	loadn r1, #Msn2
	loadn r2, #0
	call ImprimeStr
	
	halt

;----------------------------------
MoveTiroAlien_Desenha:
	push R0
	push R1
	push R2
	
	load R2, dirTiroAlien
	loadn R1, #2
	mod R1, R2, R1
	loadn R2, #0
	cmp R1, R2
	
	jne MoveTiroAlien_Horizontal
	Loadn R1, #58	; Tiro
	jmp MoveTiroAlien_Fim
	
	MoveTiroAlien_Horizontal:
	loadn R1, #45
	
	MoveTiroAlien_Fim:
	load R0, posTiroAlien
	outchar R1, R0
	store posAntTiroAlien, R0
	
	pop R2
	pop R1
	pop R0
	rts

;----------------------------------

;********************************************************
;                       DELAY
;********************************************************		


Delay:
						;Utiliza Push e Pop para nao afetar os Ristradores do programa principal
	Push R0
	Push R1
	
	Loadn R1, #10  ; a
   Delay_volta2:				;Quebrou o contador acima em duas partes (dois loops de decremento)
	Loadn R0, #5000	; b
   Delay_volta: 
	Dec R0					; (4*a + 6)b = 1000000  == 1 seg  em um clock de 1MHz
	JNZ Delay_volta	
	Dec R1
	JNZ Delay_volta2
	
	Pop R1
	Pop R0
	
	RTS							;return

;-------------------------------

;********************************************************
;						FUNÇÕES PARA TELAS
;---------------------------------------------------------
; Verifica a variável 'nFase' e desenha o mapa correto
;---------------------------------------------------------
GerenciaFases:
  push R0
  push R1
  
  load R0, nFase
  
   ; -- Verifica Fase 1 --
   loadn R1, #1
   cmp R0, R1
   jeq GerenciaFases_Fase1
   
    ; -- Verifica Fase 2 --
    loadn R1, #2
    cmp R0, R1
    jeq GerenciaFases_Fase2
    
    ; -- Verifica Fase 3 --
    loadn R1, #3
    cmp R0, R1
    jeq GerenciaFases_Fase3
    
    ; -- Verifica Fase 4 --
    loadn R1, #4
    cmp R0, R1
    jeq GerenciaFases_Fase4
    
    ; -- Verifica Fase 5 --
    loadn R1, #5
    cmp R0, R1
    jeq GerenciaFases_Fase5
    
    jmp GerenciaFases_Fim
    
    GerenciaFases_Fase1:
    call DesenhaFase1
    jmp GerenciaFases_Fim
    
    GerenciaFases_Fase2:
    call DesenhaFase2
    jmp GerenciaFases_Fim
    
    GerenciaFases_Fase3:
    call DesenhaFase3
    jmp GerenciaFases_Fim
    
    GerenciaFases_Fase4:
    call DesenhaFase4
    jmp GerenciaFases_Fim
    
    GerenciaFases_Fase5:
    call DesenhaFase5
    jmp GerenciaFases_Fim

	GerenciaFases_Fim:
  	pop R1
  	pop R0
  	rts

DesenhaFase1:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #MapaFase1	; Carrega o endereço do mapa da fase 1
  store PtrMapaAtual, R0
  loadn R1, #0			; Posição na tela (começa em 0)
  loadn R2, #1200		; Total de pixels

  DesenhaFase1Loop:

    add R3,R0,R1		; R3 = Endereço base do mapa + Offset atual
    loadi R3, R3		; Carrega o valor (cor + char) que está no mapa
    outchar R3, R1		; Joga na tela na posição R1
    inc R1
    cmp R1, R2

    jne DesenhaFase1Loop

  pop R3
  pop R2
  pop R1
  pop R0
  rts
  
DesenhaFase2:
    push R0
    push R1
    push R2
    push R3
    push R4

    loadn R0, #MapaFase2  ; <--- AQUI: Carrega o Mapa da Fase 2
    store PtrMapaAtual, R0
    loadn R1, #0          ; Posição na tela
    loadn R2, #1200       ; Limite
    loadn R4, #3967       ; Fundo vazio (transparente)

	DesenhaFase2_Loop:
    add R3, R0, R1        ; Calcula endereço
    loadi R3, R3          ; Carrega o char do mapa

    cmp R3, R4            ; É um espaço vazio?
    jeq DesenhaFase2_Skip ; Se for vazio, não imprime

    outchar R3, R1        ; Se for parede, imprime

	DesenhaFase2_Skip:
    inc R1
    cmp R1, R2
    jne DesenhaFase2_Loop

    pop R4
    pop R3
    pop R2
    pop R1
    pop R0
    rts
    
DesenhaFase3:
    push R0
    push R1
    push R2
    push R3
    push R4

    loadn R0, #MapaFase3  ; <--- AQUI: Carrega o Mapa da Fase 3
    store PtrMapaAtual, R0
    loadn R1, #0          ; Posição na tela
    loadn R2, #1200       ; Limite
    loadn R4, #3967       ; Fundo vazio (transparente)

	DesenhaFase3_Loop:
    add R3, R0, R1        ; Calcula endereço
    loadi R3, R3          ; Carrega o char do mapa

    cmp R3, R4            ; É um espaço vazio?
    jeq DesenhaFase3_Skip ; Se for vazio, não imprime

    outchar R3, R1        ; Se for parede, imprime

	DesenhaFase3_Skip:
    inc R1
    cmp R1, R2
    jne DesenhaFase3_Loop

    pop R4
    pop R3
    pop R2
    pop R1
    pop R0
    rts
    
DesenhaFase4:
    push R0
    push R1
    push R2
    push R3
    push R4

    loadn R0, #MapaFase4  ; <--- AQUI: Carrega o Mapa da Fase 4
    store PtrMapaAtual, R0
    loadn R1, #0          ; Posição na tela
    loadn R2, #1200       ; Limite
    loadn R4, #3967       ; Fundo vazio (transparente)

	DesenhaFase4_Loop:
    add R3, R0, R1        ; Calcula endereço
    loadi R3, R3          ; Carrega o char do mapa

    cmp R3, R4            ; É um espaço vazio?
    jeq DesenhaFase4_Skip ; Se for vazio, não imprime

    outchar R3, R1        ; Se for parede, imprime

	DesenhaFase4_Skip:
    inc R1
    cmp R1, R2
    jne DesenhaFase4_Loop

    pop R4
    pop R3
    pop R2
    pop R1
    pop R0
    rts
    
DesenhaFase5:
    push R0
    push R1
    push R2
    push R3
    push R4

    loadn R0, #MapaFase5  ; <--- AQUI: Carrega o Mapa da Fase 5
    store PtrMapaAtual, R0
    loadn R1, #0          ; Posição na tela
    loadn R2, #1200       ; Limite
    loadn R4, #3967       ; Fundo vazio (transparente)

	DesenhaFase5_Loop:
    add R3, R0, R1        ; Calcula endereço
    loadi R3, R3          ; Carrega o char do mapa

    cmp R3, R4            ; É um espaço vazio?
    jeq DesenhaFase5_Skip ; Se for vazio, não imprime

    outchar R3, R1        ; Se for parede, imprime

	DesenhaFase5_Skip:
    inc R1
    cmp R1, R2
    jne DesenhaFase5_Loop

    pop R4
    pop R3
    pop R2
    pop R1
    pop R0
    rts

;********************************************************
;                       IMPRIME TELA
;********************************************************	

ImprimeTela: 	;  Rotina de Impresao de Cenario na Tela Inteira
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r4 na pilha para ser usado na subrotina

	loadn R0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn R3, #40  	; Incremento da posicao da tela!
	loadn R4, #41  	; incremento do ponteiro das linhas da tela
	loadn R5, #1200 ; Limite da tela!
	
   ImprimeTela_Loop:
		call ImprimeStr
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ImprimeTela_Loop	; Enquanto r0 < 1200

	pop r5	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
ImprimeUI:
	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	
	load R0, nVidasNave
	load R2, nFase
	loadn R1, #48
	add R0, R0, R1
	add R2, R2, R1
	loadn R1, #47
	outchar R0, R1 ; imprime o numero de vidas
	loadn R1, #78
	outchar R2, R1 ; imprime a fase
	
	pop r2
	pop r1
	pop r0
	rts
;---------------------

;---------------------------	
;********************************************************
;                   IMPRIME STRING
;********************************************************
	
ImprimeStr:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Criterio de parada

   ImprimeStr_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStr_Sai
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		jmp ImprimeStr_Loop
	
   ImprimeStr_Sai:	
	pop r4	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
;------------------------	
	

;-------------------------------


;********************************************************
;                       IMPRIME TELA2
;********************************************************	

ImprimeTela2: 	;  Rotina de Impresao de Cenario na Tela Inteira
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina

	loadn R0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn R3, #40  	; Incremento da posicao da tela!
	loadn R4, #41  	; incremento do ponteiro das linhas da tela
	loadn R5, #1200 ; Limite da tela!
	loadn R6, #tela0Linha0	; Endereco onde comeca a primeira linha do cenario!!
	
   ImprimeTela2_Loop:
		call ImprimeStr2
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		add r6, r6, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ImprimeTela2_Loop	; Enquanto r0 < 1200

	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
				
;---------------------

;---------------------------	
;********************************************************
;                   IMPRIME STRING2
;********************************************************
	
ImprimeStr2:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina
	
	
	loadn r3, #'\0'	; Criterio de parada
	loadn r5, #' '	; Espaco em Branco

   ImprimeStr2_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStr2_Sai
		cmp r4, r5		; If (Char == ' ')  vai Pula outchar do espaco para na apagar outros caracteres
		jeq ImprimeStr2_Skip
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
		storei r6, r4
   ImprimeStr2_Skip:
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		inc r6			; Incrementa o ponteiro da String da Tela 0
		jmp ImprimeStr2_Loop
	
   ImprimeStr2_Sai:	
	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	

;------------------------		
;********************************************************
;                   DIGITE UMA LETRA
;********************************************************

DigLetra:	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	push r0
	push r1
	loadn r1, #255	; Se nao digitar nada vem 255

   DigLetra_Loop:
		inchar r0			; Le o teclado, se nada for digitado = 255
		cmp r0, r1			;compara r0 com 255
		jeq DigLetra_Loop	; Fica lendo ate' que digite uma tecla valida

	store Letra, r0			; Salva a tecla na variavel global "Letra"

	pop r1
	pop r0
	rts



;----------------
	
;********************************************************
;                       APAGA TELA
;********************************************************
ApagaTela:
	push r0
	push r1
	
	loadn r0, #1200		; apaga as 1200 posicoes da Tela
	loadn r1, #' '		; com "espaco"
	
	   ApagaTela_Loop:	;;label for(r0=1200;r3>0;r3--)
		dec r0
		outchar r1, r0
		jnz ApagaTela_Loop
 
	pop r1
	pop r0
	rts	
	
;------------------------	
; Declara uma tela vazia para ser preenchida em tempo de execussao:

tela0Linha0  : string "                                        "
tela0Linha1  : string "                                        "
tela0Linha2  : string "                                        "
tela0Linha3  : string "                                        "
tela0Linha4  : string "                                        "
tela0Linha5  : string "                                        "
tela0Linha6  : string "                                        "
tela0Linha7  : string "                                        "
tela0Linha8  : string "                                        "
tela0Linha9  : string "                                        "
tela0Linha10 : string "                                        "
tela0Linha11 : string "                                        "
tela0Linha12 : string "                                        "
tela0Linha13 : string "                                        "
tela0Linha14 : string "                                        "
tela0Linha15 : string "                                        "
tela0Linha16 : string "                                        "
tela0Linha17 : string "                                        "
tela0Linha18 : string "                                        "
tela0Linha19 : string "                                        "
tela0Linha20 : string "                                        "
tela0Linha21 : string "                                        "
tela0Linha22 : string "                                        "
tela0Linha23 : string "                                        "
tela0Linha24 : string "                                        "
tela0Linha25 : string "                                        "
tela0Linha26 : string "                                        "
tela0Linha27 : string "                                        "
tela0Linha28 : string "                                        "
tela0Linha29 : string "                                        "	

; Declara e preenche tela linha por linha (40 caracteres):
tela2Linha0  : string "                                        "
tela2Linha1  : string "              a new hope                "
tela2Linha2  : string "                                        "
tela2Linha3  : string "                                        "
tela2Linha4  : string "                                        "
tela2Linha5  : string "                                        "
tela2Linha6  : string "                                        "
tela2Linha7  : string "                                        "
tela2Linha8  : string "                                        "
tela2Linha9  : string "                                        "
tela2Linha10 : string "                                        "
tela2Linha11 : string "                                        "
tela2Linha12 : string "                                        "
tela2Linha13 : string "                                        "
tela2Linha14 : string "                                        "
tela2Linha15 : string "                                        "
tela2Linha16 : string "                                        "
tela2Linha17 : string "                                        "
tela2Linha18 : string "                                        "
tela2Linha19 : string "                                        "
tela2Linha20 : string "                                        "
tela2Linha21 : string "                                        "
tela2Linha22 : string "                                        "
tela2Linha23 : string "                                        "
tela2Linha24 : string "                                        "
tela2Linha25 : string "                                        "
tela2Linha26 : string "                                        "
tela2Linha27 : string "                                        "
tela2Linha28 : string "                                        "
tela2Linha29 : string "                                        "

tela3Linha0  : string "========================================"
tela3Linha1  : string ":vida&  :                     : fase&  :"
tela3Linha2  : string "========================================"
tela3Linha3  : string "                                        "
tela3Linha4  : string "                                        "
tela3Linha5  : string "                                        "
tela3Linha6  : string "                                        "
tela3Linha7  : string "                                        "
tela3Linha8  : string "                                        "
tela3Linha9  : string "                                        "
tela3Linha10 : string "                                        "
tela3Linha11 : string "                                        "
tela3Linha12 : string "                                        "
tela3Linha13 : string "                                        "
tela3Linha14 : string "                                        "
tela3Linha15 : string "                                        "
tela3Linha16 : string "                                        "
tela3Linha17 : string "                                        "
tela3Linha18 : string "                                        "
tela3Linha19 : string "                                        "
tela3Linha20 : string "                                        "
tela3Linha21 : string "                                        "
tela3Linha22 : string "                                        "
tela3Linha23 : string "                                        "
tela3Linha24 : string "                                        "
tela3Linha25 : string "                                        "
tela3Linha26 : string "                                        "
tela3Linha27 : string "                                        "
tela3Linha28 : string "                                        "
tela3Linha29 : string "                                        "

MapaFase1 : var #1200
  ;Linha 0
  static MapaFase1 + #0, #3967
  static MapaFase1 + #1, #3967
  static MapaFase1 + #2, #3967
  static MapaFase1 + #3, #3967
  static MapaFase1 + #4, #3967
  static MapaFase1 + #5, #3967
  static MapaFase1 + #6, #3967
  static MapaFase1 + #7, #3967
  static MapaFase1 + #8, #3967
  static MapaFase1 + #9, #3967
  static MapaFase1 + #10, #3967
  static MapaFase1 + #11, #3967
  static MapaFase1 + #12, #3967
  static MapaFase1 + #13, #3967
  static MapaFase1 + #14, #3967
  static MapaFase1 + #15, #3967
  static MapaFase1 + #16, #3967
  static MapaFase1 + #17, #3967
  static MapaFase1 + #18, #3967
  static MapaFase1 + #19, #3967
  static MapaFase1 + #20, #3967
  static MapaFase1 + #21, #3967
  static MapaFase1 + #22, #3967
  static MapaFase1 + #23, #3967
  static MapaFase1 + #24, #3967
  static MapaFase1 + #25, #3967
  static MapaFase1 + #26, #3967
  static MapaFase1 + #27, #3967
  static MapaFase1 + #28, #0
  static MapaFase1 + #29, #3967
  static MapaFase1 + #30, #3967
  static MapaFase1 + #31, #3967
  static MapaFase1 + #32, #3967
  static MapaFase1 + #33, #3967
  static MapaFase1 + #34, #3967
  static MapaFase1 + #35, #3967
  static MapaFase1 + #36, #3967
  static MapaFase1 + #37, #3967
  static MapaFase1 + #38, #3967
  static MapaFase1 + #39, #3967

  ;Linha 1
  static MapaFase1 + #40, #3967
  static MapaFase1 + #41, #3967
  static MapaFase1 + #42, #3967
  static MapaFase1 + #43, #3967
  static MapaFase1 + #44, #3967
  static MapaFase1 + #45, #3967
  static MapaFase1 + #46, #3967
  static MapaFase1 + #47, #3967
  static MapaFase1 + #48, #3967
  static MapaFase1 + #49, #3967
  static MapaFase1 + #50, #3967
  static MapaFase1 + #51, #3967
  static MapaFase1 + #52, #3967
  static MapaFase1 + #53, #3967
  static MapaFase1 + #54, #3967
  static MapaFase1 + #55, #3967
  static MapaFase1 + #56, #3967
  static MapaFase1 + #57, #3967
  static MapaFase1 + #58, #3967
  static MapaFase1 + #59, #3967
  static MapaFase1 + #60, #3967
  static MapaFase1 + #61, #3967
  static MapaFase1 + #62, #3967
  static MapaFase1 + #63, #3967
  static MapaFase1 + #64, #3967
  static MapaFase1 + #65, #3967
  static MapaFase1 + #66, #3967
  static MapaFase1 + #67, #3967
  static MapaFase1 + #68, #0
  static MapaFase1 + #69, #3967
  static MapaFase1 + #70, #3967
  static MapaFase1 + #71, #3967
  static MapaFase1 + #72, #3967
  static MapaFase1 + #73, #3967
  static MapaFase1 + #74, #3878
  static MapaFase1 + #75, #3878
  static MapaFase1 + #76, #3878
  static MapaFase1 + #77, #3967
  static MapaFase1 + #78, #3967
  static MapaFase1 + #79, #3967

  ;Linha 2
  static MapaFase1 + #80, #3967
  static MapaFase1 + #81, #3967
  static MapaFase1 + #82, #3967
  static MapaFase1 + #83, #3967
  static MapaFase1 + #84, #3967
  static MapaFase1 + #85, #3967
  static MapaFase1 + #86, #3967
  static MapaFase1 + #87, #3967
  static MapaFase1 + #88, #3967
  static MapaFase1 + #89, #3967
  static MapaFase1 + #90, #3967
  static MapaFase1 + #91, #3967
  static MapaFase1 + #92, #3967
  static MapaFase1 + #93, #3967
  static MapaFase1 + #94, #3967
  static MapaFase1 + #95, #3967
  static MapaFase1 + #96, #3967
  static MapaFase1 + #97, #3967
  static MapaFase1 + #98, #3967
  static MapaFase1 + #99, #3967
  static MapaFase1 + #100, #3967
  static MapaFase1 + #101, #3967
  static MapaFase1 + #102, #3967
  static MapaFase1 + #103, #3967
  static MapaFase1 + #104, #3967
  static MapaFase1 + #105, #3967
  static MapaFase1 + #106, #3967
  static MapaFase1 + #107, #3967
  static MapaFase1 + #108, #3967
  static MapaFase1 + #109, #3967
  static MapaFase1 + #110, #3967
  static MapaFase1 + #111, #3967
  static MapaFase1 + #112, #3967
  static MapaFase1 + #113, #3967
  static MapaFase1 + #114, #3878
  static MapaFase1 + #115, #3878
  static MapaFase1 + #116, #3878
  static MapaFase1 + #117, #3967
  static MapaFase1 + #118, #1066
  static MapaFase1 + #119, #3967

  ;Linha 3
  static MapaFase1 + #120, #3967
  static MapaFase1 + #121, #3967
  static MapaFase1 + #122, #3967
  static MapaFase1 + #123, #3967
  static MapaFase1 + #124, #3967
  static MapaFase1 + #125, #3967
  static MapaFase1 + #126, #3967
  static MapaFase1 + #127, #3967
  static MapaFase1 + #128, #3967
  static MapaFase1 + #129, #3967
  static MapaFase1 + #130, #3967
  static MapaFase1 + #131, #3967
  static MapaFase1 + #132, #3967
  static MapaFase1 + #133, #3967
  static MapaFase1 + #134, #3967
  static MapaFase1 + #135, #3967
  static MapaFase1 + #136, #3967
  static MapaFase1 + #137, #3967
  static MapaFase1 + #138, #3967
  static MapaFase1 + #139, #3967
  static MapaFase1 + #140, #3967
  static MapaFase1 + #141, #3967
  static MapaFase1 + #142, #3967
  static MapaFase1 + #143, #3967
  static MapaFase1 + #144, #3967
  static MapaFase1 + #145, #3967
  static MapaFase1 + #146, #3967
  static MapaFase1 + #147, #3967
  static MapaFase1 + #148, #3967
  static MapaFase1 + #149, #3967
  static MapaFase1 + #150, #3967
  static MapaFase1 + #151, #3967
  static MapaFase1 + #152, #3967
  static MapaFase1 + #153, #3967
  static MapaFase1 + #154, #3878
  static MapaFase1 + #155, #3878
  static MapaFase1 + #156, #3878
  static MapaFase1 + #157, #3967
  static MapaFase1 + #158, #3967
  static MapaFase1 + #159, #3967

  ;Linha 4
  static MapaFase1 + #160, #3967
  static MapaFase1 + #161, #3967
  static MapaFase1 + #162, #3967
  static MapaFase1 + #163, #3967
  static MapaFase1 + #164, #3967
  static MapaFase1 + #165, #3967
  static MapaFase1 + #166, #3967
  static MapaFase1 + #167, #3967
  static MapaFase1 + #168, #3967
  static MapaFase1 + #169, #3967
  static MapaFase1 + #170, #3967
  static MapaFase1 + #171, #3967
  static MapaFase1 + #172, #3967
  static MapaFase1 + #173, #3967
  static MapaFase1 + #174, #3967
  static MapaFase1 + #175, #3967
  static MapaFase1 + #176, #3967
  static MapaFase1 + #177, #3967
  static MapaFase1 + #178, #3967
  static MapaFase1 + #179, #3967
  static MapaFase1 + #180, #3967
  static MapaFase1 + #181, #3967
  static MapaFase1 + #182, #3967
  static MapaFase1 + #183, #3967
  static MapaFase1 + #184, #3967
  static MapaFase1 + #185, #3967
  static MapaFase1 + #186, #3967
  static MapaFase1 + #187, #3967
  static MapaFase1 + #188, #3967
  static MapaFase1 + #189, #3967
  static MapaFase1 + #190, #3967
  static MapaFase1 + #191, #1885
  static MapaFase1 + #192, #1883
  static MapaFase1 + #193, #1827
  static MapaFase1 + #194, #3967
  static MapaFase1 + #195, #3967
  static MapaFase1 + #196, #3967
  static MapaFase1 + #197, #3967
  static MapaFase1 + #198, #3967
  static MapaFase1 + #199, #3967

  ;Linha 5
  static MapaFase1 + #200, #3967
  static MapaFase1 + #201, #3967
  static MapaFase1 + #202, #3967
  static MapaFase1 + #203, #3967
  static MapaFase1 + #204, #1088
  static MapaFase1 + #205, #3967
  static MapaFase1 + #206, #3967
  static MapaFase1 + #207, #3967
  static MapaFase1 + #208, #3967
  static MapaFase1 + #209, #3967
  static MapaFase1 + #210, #3967
  static MapaFase1 + #211, #3967
  static MapaFase1 + #212, #3967
  static MapaFase1 + #213, #3967
  static MapaFase1 + #214, #3967
  static MapaFase1 + #215, #3967
  static MapaFase1 + #216, #3967
  static MapaFase1 + #217, #3967
  static MapaFase1 + #218, #3967
  static MapaFase1 + #219, #3967
  static MapaFase1 + #220, #3967
  static MapaFase1 + #221, #3967
  static MapaFase1 + #222, #3967
  static MapaFase1 + #223, #3967
  static MapaFase1 + #224, #3967
  static MapaFase1 + #225, #3967
  static MapaFase1 + #226, #3967
  static MapaFase1 + #227, #3967
  static MapaFase1 + #228, #3967
  static MapaFase1 + #229, #3967
  static MapaFase1 + #230, #3967
  static MapaFase1 + #231, #1916
  static MapaFase1 + #232, #1884
  static MapaFase1 + #233, #1917
  static MapaFase1 + #234, #3967
  static MapaFase1 + #235, #3967
  static MapaFase1 + #236, #3967
  static MapaFase1 + #237, #3967
  static MapaFase1 + #238, #3967
  static MapaFase1 + #239, #3967

  ;Linha 6
  static MapaFase1 + #240, #3967
  static MapaFase1 + #241, #3967
  static MapaFase1 + #242, #3967
  static MapaFase1 + #243, #3967
  static MapaFase1 + #244, #3967
  static MapaFase1 + #245, #3967
  static MapaFase1 + #246, #3967
  static MapaFase1 + #247, #3967
  static MapaFase1 + #248, #3967
  static MapaFase1 + #249, #3967
  static MapaFase1 + #250, #3967
  static MapaFase1 + #251, #3967
  static MapaFase1 + #252, #3967
  static MapaFase1 + #253, #3967
  static MapaFase1 + #254, #3967
  static MapaFase1 + #255, #3967
  static MapaFase1 + #256, #3967
  static MapaFase1 + #257, #3967
  static MapaFase1 + #258, #3967
  static MapaFase1 + #259, #3967
  static MapaFase1 + #260, #3967
  static MapaFase1 + #261, #3967
  static MapaFase1 + #262, #3967
  static MapaFase1 + #263, #3967
  static MapaFase1 + #264, #3967
  static MapaFase1 + #265, #3967
  static MapaFase1 + #266, #3967
  static MapaFase1 + #267, #3967
  static MapaFase1 + #268, #3967
  static MapaFase1 + #269, #3967
  static MapaFase1 + #270, #3967
  static MapaFase1 + #271, #1886
  static MapaFase1 + #272, #1915
  static MapaFase1 + #273, #1887
  static MapaFase1 + #274, #3967
  static MapaFase1 + #275, #3967
  static MapaFase1 + #276, #3967
  static MapaFase1 + #277, #3967
  static MapaFase1 + #278, #3967
  static MapaFase1 + #279, #3967

  ;Linha 7
  static MapaFase1 + #280, #3967
  static MapaFase1 + #281, #3967
  static MapaFase1 + #282, #3967
  static MapaFase1 + #283, #3967
  static MapaFase1 + #284, #3967
  static MapaFase1 + #285, #3967
  static MapaFase1 + #286, #3967
  static MapaFase1 + #287, #3967
  static MapaFase1 + #288, #3967
  static MapaFase1 + #289, #3967
  static MapaFase1 + #290, #3967
  static MapaFase1 + #291, #3967
  static MapaFase1 + #292, #3967
  static MapaFase1 + #293, #3967
  static MapaFase1 + #294, #3967
  static MapaFase1 + #295, #3967
  static MapaFase1 + #296, #3967
  static MapaFase1 + #297, #3967
  static MapaFase1 + #298, #3967
  static MapaFase1 + #299, #3967
  static MapaFase1 + #300, #3967
  static MapaFase1 + #301, #3967
  static MapaFase1 + #302, #3967
  static MapaFase1 + #303, #3967
  static MapaFase1 + #304, #3967
  static MapaFase1 + #305, #3967
  static MapaFase1 + #306, #3967
  static MapaFase1 + #307, #3967
  static MapaFase1 + #308, #3967
  static MapaFase1 + #309, #3967
  static MapaFase1 + #310, #3967
  static MapaFase1 + #311, #3967
  static MapaFase1 + #312, #3967
  static MapaFase1 + #313, #3967
  static MapaFase1 + #314, #3967
  static MapaFase1 + #315, #3967
  static MapaFase1 + #316, #3967
  static MapaFase1 + #317, #3967
  static MapaFase1 + #318, #3967
  static MapaFase1 + #319, #3967

  ;Linha 8
  static MapaFase1 + #320, #3967
  static MapaFase1 + #321, #3967
  static MapaFase1 + #322, #3967
  static MapaFase1 + #323, #3967
  static MapaFase1 + #324, #3967
  static MapaFase1 + #325, #3967
  static MapaFase1 + #326, #3967
  static MapaFase1 + #327, #3967
  static MapaFase1 + #328, #3967
  static MapaFase1 + #329, #3967
  static MapaFase1 + #330, #3967
  static MapaFase1 + #331, #3967
  static MapaFase1 + #332, #3967
  static MapaFase1 + #333, #3967
  static MapaFase1 + #334, #3967
  static MapaFase1 + #335, #3967
  static MapaFase1 + #336, #3967
  static MapaFase1 + #337, #3967
  static MapaFase1 + #338, #3967
  static MapaFase1 + #339, #3967
  static MapaFase1 + #340, #3967
  static MapaFase1 + #341, #3967
  static MapaFase1 + #342, #3967
  static MapaFase1 + #343, #3967
  static MapaFase1 + #344, #3967
  static MapaFase1 + #345, #3967
  static MapaFase1 + #346, #3967
  static MapaFase1 + #347, #3967
  static MapaFase1 + #348, #3967
  static MapaFase1 + #349, #3967
  static MapaFase1 + #350, #3967
  static MapaFase1 + #351, #3967
  static MapaFase1 + #352, #3967
  static MapaFase1 + #353, #3967
  static MapaFase1 + #354, #3967
  static MapaFase1 + #355, #3967
  static MapaFase1 + #356, #3967
  static MapaFase1 + #357, #3967
  static MapaFase1 + #358, #3967
  static MapaFase1 + #359, #3967

  ;Linha 9
  static MapaFase1 + #360, #3967
  static MapaFase1 + #361, #3967
  static MapaFase1 + #362, #3967
  static MapaFase1 + #363, #3967
  static MapaFase1 + #364, #3967
  static MapaFase1 + #365, #3967
  static MapaFase1 + #366, #3967
  static MapaFase1 + #367, #3967
  static MapaFase1 + #368, #3967
  static MapaFase1 + #369, #3967
  static MapaFase1 + #370, #3967
  static MapaFase1 + #371, #3967
  static MapaFase1 + #372, #1067
  static MapaFase1 + #373, #3967
  static MapaFase1 + #374, #3967
  static MapaFase1 + #375, #3967
  static MapaFase1 + #376, #3967
  static MapaFase1 + #377, #3967
  static MapaFase1 + #378, #3967
  static MapaFase1 + #379, #3967
  static MapaFase1 + #380, #3967
  static MapaFase1 + #381, #3967
  static MapaFase1 + #382, #3967
  static MapaFase1 + #383, #3904
  static MapaFase1 + #384, #1067
  static MapaFase1 + #385, #3967
  static MapaFase1 + #386, #3967
  static MapaFase1 + #387, #3967
  static MapaFase1 + #388, #3967
  static MapaFase1 + #389, #3967
  static MapaFase1 + #390, #3967
  static MapaFase1 + #391, #3967
  static MapaFase1 + #392, #3967
  static MapaFase1 + #393, #3967
  static MapaFase1 + #394, #3967
  static MapaFase1 + #395, #3967
  static MapaFase1 + #396, #3967
  static MapaFase1 + #397, #3967
  static MapaFase1 + #398, #3967
  static MapaFase1 + #399, #3967

  ;Linha 10
  static MapaFase1 + #400, #3967
  static MapaFase1 + #401, #3967
  static MapaFase1 + #402, #3967
  static MapaFase1 + #403, #3967
  static MapaFase1 + #404, #3967
  static MapaFase1 + #405, #3967
  static MapaFase1 + #406, #3967
  static MapaFase1 + #407, #3967
  static MapaFase1 + #408, #3967
  static MapaFase1 + #409, #3967
  static MapaFase1 + #410, #3967
  static MapaFase1 + #411, #3967
  static MapaFase1 + #412, #3967
  static MapaFase1 + #413, #3967
  static MapaFase1 + #414, #3967
  static MapaFase1 + #415, #3967
  static MapaFase1 + #416, #3967
  static MapaFase1 + #417, #3967
  static MapaFase1 + #418, #3967
  static MapaFase1 + #419, #3967
  static MapaFase1 + #420, #3967
  static MapaFase1 + #421, #3967
  static MapaFase1 + #422, #3967
  static MapaFase1 + #423, #3967
  static MapaFase1 + #424, #3967
  static MapaFase1 + #425, #3967
  static MapaFase1 + #426, #3967
  static MapaFase1 + #427, #3967
  static MapaFase1 + #428, #3967
  static MapaFase1 + #429, #3967
  static MapaFase1 + #430, #3967
  static MapaFase1 + #431, #3967
  static MapaFase1 + #432, #3967
  static MapaFase1 + #433, #3967
  static MapaFase1 + #434, #3967
  static MapaFase1 + #435, #3967
  static MapaFase1 + #436, #3967
  static MapaFase1 + #437, #3967
  static MapaFase1 + #438, #3967
  static MapaFase1 + #439, #3967

  ;Linha 11
  static MapaFase1 + #440, #3967
  static MapaFase1 + #441, #3967
  static MapaFase1 + #442, #3967
  static MapaFase1 + #443, #3967
  static MapaFase1 + #444, #3967
  static MapaFase1 + #445, #3967
  static MapaFase1 + #446, #3967
  static MapaFase1 + #447, #3967
  static MapaFase1 + #448, #3967
  static MapaFase1 + #449, #3967
  static MapaFase1 + #450, #3967
  static MapaFase1 + #451, #3967
  static MapaFase1 + #452, #3967
  static MapaFase1 + #453, #3967
  static MapaFase1 + #454, #3967
  static MapaFase1 + #455, #3967
  static MapaFase1 + #456, #3967
  static MapaFase1 + #457, #3967
  static MapaFase1 + #458, #3967
  static MapaFase1 + #459, #3967
  static MapaFase1 + #460, #3967
  static MapaFase1 + #461, #3967
  static MapaFase1 + #462, #3967
  static MapaFase1 + #463, #3967
  static MapaFase1 + #464, #3967
  static MapaFase1 + #465, #3967
  static MapaFase1 + #466, #3967
  static MapaFase1 + #467, #3967
  static MapaFase1 + #468, #3967
  static MapaFase1 + #469, #3967
  static MapaFase1 + #470, #3967
  static MapaFase1 + #471, #3967
  static MapaFase1 + #472, #3967
  static MapaFase1 + #473, #3967
  static MapaFase1 + #474, #3967
  static MapaFase1 + #475, #3967
  static MapaFase1 + #476, #3967
  static MapaFase1 + #477, #3967
  static MapaFase1 + #478, #3967
  static MapaFase1 + #479, #3967

  ;Linha 12
  static MapaFase1 + #480, #3967
  static MapaFase1 + #481, #3967
  static MapaFase1 + #482, #3967
  static MapaFase1 + #483, #3967
  static MapaFase1 + #484, #3967
  static MapaFase1 + #485, #3967
  static MapaFase1 + #486, #3967
  static MapaFase1 + #487, #3967
  static MapaFase1 + #488, #3967
  static MapaFase1 + #489, #3967
  static MapaFase1 + #490, #3967
  static MapaFase1 + #491, #3967
  static MapaFase1 + #492, #3967
  static MapaFase1 + #493, #3967
  static MapaFase1 + #494, #3967
  static MapaFase1 + #495, #3967
  static MapaFase1 + #496, #3967
  static MapaFase1 + #497, #3967
  static MapaFase1 + #498, #3967
  static MapaFase1 + #499, #3967
  static MapaFase1 + #500, #3967
  static MapaFase1 + #501, #3967
  static MapaFase1 + #502, #3967
  static MapaFase1 + #503, #3967
  static MapaFase1 + #504, #3967
  static MapaFase1 + #505, #3967
  static MapaFase1 + #506, #3967
  static MapaFase1 + #507, #3967
  static MapaFase1 + #508, #3967
  static MapaFase1 + #509, #3967
  static MapaFase1 + #510, #3967
  static MapaFase1 + #511, #3967
  static MapaFase1 + #512, #3967
  static MapaFase1 + #513, #3967
  static MapaFase1 + #514, #3967
  static MapaFase1 + #515, #3967
  static MapaFase1 + #516, #3967
  static MapaFase1 + #517, #3967
  static MapaFase1 + #518, #3967
  static MapaFase1 + #519, #3967

  ;Linha 13
  static MapaFase1 + #520, #3967
  static MapaFase1 + #521, #3967
  static MapaFase1 + #522, #3967
  static MapaFase1 + #523, #3967
  static MapaFase1 + #524, #3967
  static MapaFase1 + #525, #3967
  static MapaFase1 + #526, #3967
  static MapaFase1 + #527, #3967
  static MapaFase1 + #528, #3967
  static MapaFase1 + #529, #3967
  static MapaFase1 + #530, #3967
  static MapaFase1 + #531, #3967
  static MapaFase1 + #532, #3967
  static MapaFase1 + #533, #3967
  static MapaFase1 + #534, #3967
  static MapaFase1 + #535, #3967
  static MapaFase1 + #536, #3967
  static MapaFase1 + #537, #3967
  static MapaFase1 + #538, #3967
  static MapaFase1 + #539, #3967
  static MapaFase1 + #540, #3967
  static MapaFase1 + #541, #3967
  static MapaFase1 + #542, #3967
  static MapaFase1 + #543, #3967
  static MapaFase1 + #544, #3967
  static MapaFase1 + #545, #3967
  static MapaFase1 + #546, #3967
  static MapaFase1 + #547, #3967
  static MapaFase1 + #548, #3967
  static MapaFase1 + #549, #3967
  static MapaFase1 + #550, #3967
  static MapaFase1 + #551, #3967
  static MapaFase1 + #552, #3967
  static MapaFase1 + #553, #3967
  static MapaFase1 + #554, #3967
  static MapaFase1 + #555, #3967
  static MapaFase1 + #556, #3967
  static MapaFase1 + #557, #3967
  static MapaFase1 + #558, #3967
  static MapaFase1 + #559, #3967

  ;Linha 14
  static MapaFase1 + #560, #3967
  static MapaFase1 + #561, #3967
  static MapaFase1 + #562, #3967
  static MapaFase1 + #563, #3967
  static MapaFase1 + #564, #3967
  static MapaFase1 + #565, #3967
  static MapaFase1 + #566, #3967
  static MapaFase1 + #567, #3967
  static MapaFase1 + #568, #3967
  static MapaFase1 + #569, #3967
  static MapaFase1 + #570, #3967
  static MapaFase1 + #571, #3967
  static MapaFase1 + #572, #3967
  static MapaFase1 + #573, #3967
  static MapaFase1 + #574, #3967
  static MapaFase1 + #575, #3967
  static MapaFase1 + #576, #3967
  static MapaFase1 + #577, #3967
  static MapaFase1 + #578, #3967
  static MapaFase1 + #579, #3967
  static MapaFase1 + #580, #3967
  static MapaFase1 + #581, #3967
  static MapaFase1 + #582, #3967
  static MapaFase1 + #583, #3967
  static MapaFase1 + #584, #3967
  static MapaFase1 + #585, #3967
  static MapaFase1 + #586, #3967
  static MapaFase1 + #587, #3967
  static MapaFase1 + #588, #3967
  static MapaFase1 + #589, #3967
  static MapaFase1 + #590, #3967
  static MapaFase1 + #591, #3967
  static MapaFase1 + #592, #3967
  static MapaFase1 + #593, #3967
  static MapaFase1 + #594, #3967
  static MapaFase1 + #595, #3967
  static MapaFase1 + #596, #3967
  static MapaFase1 + #597, #3967
  static MapaFase1 + #598, #3967
  static MapaFase1 + #599, #3967

  ;Linha 15
  static MapaFase1 + #600, #3967
  static MapaFase1 + #601, #3967
  static MapaFase1 + #602, #3967
  static MapaFase1 + #603, #3967
  static MapaFase1 + #604, #3967
  static MapaFase1 + #605, #3967
  static MapaFase1 + #606, #3967
  static MapaFase1 + #607, #3967
  static MapaFase1 + #608, #3967
  static MapaFase1 + #609, #3967
  static MapaFase1 + #610, #3967
  static MapaFase1 + #611, #3967
  static MapaFase1 + #612, #3967
  static MapaFase1 + #613, #3967
  static MapaFase1 + #614, #3967
  static MapaFase1 + #615, #3967
  static MapaFase1 + #616, #3967
  static MapaFase1 + #617, #3967
  static MapaFase1 + #618, #3967
  static MapaFase1 + #619, #3967
  static MapaFase1 + #620, #3967
  static MapaFase1 + #621, #3967
  static MapaFase1 + #622, #3967
  static MapaFase1 + #623, #3967
  static MapaFase1 + #624, #3967
  static MapaFase1 + #625, #3967
  static MapaFase1 + #626, #3967
  static MapaFase1 + #627, #3967
  static MapaFase1 + #628, #3967
  static MapaFase1 + #629, #3967
  static MapaFase1 + #630, #3967
  static MapaFase1 + #631, #3967
  static MapaFase1 + #632, #3967
  static MapaFase1 + #633, #3967
  static MapaFase1 + #634, #3967
  static MapaFase1 + #635, #3967
  static MapaFase1 + #636, #3967
  static MapaFase1 + #637, #3967
  static MapaFase1 + #638, #3967
  static MapaFase1 + #639, #3967

  ;Linha 16
  static MapaFase1 + #640, #3967
  static MapaFase1 + #641, #3967
  static MapaFase1 + #642, #3967
  static MapaFase1 + #643, #3967
  static MapaFase1 + #644, #3967
  static MapaFase1 + #645, #3967
  static MapaFase1 + #646, #3967
  static MapaFase1 + #647, #3967
  static MapaFase1 + #648, #3967
  static MapaFase1 + #649, #3967
  static MapaFase1 + #650, #3967
  static MapaFase1 + #651, #3967
  static MapaFase1 + #652, #3967
  static MapaFase1 + #653, #3967
  static MapaFase1 + #654, #3967
  static MapaFase1 + #655, #3967
  static MapaFase1 + #656, #3967
  static MapaFase1 + #657, #3967
  static MapaFase1 + #658, #3967
  static MapaFase1 + #659, #3967
  static MapaFase1 + #660, #3967
  static MapaFase1 + #661, #3967
  static MapaFase1 + #662, #3967
  static MapaFase1 + #663, #3967
  static MapaFase1 + #664, #3967
  static MapaFase1 + #665, #3967
  static MapaFase1 + #666, #3967
  static MapaFase1 + #667, #3967
  static MapaFase1 + #668, #3967
  static MapaFase1 + #669, #3967
  static MapaFase1 + #670, #3967
  static MapaFase1 + #671, #3967
  static MapaFase1 + #672, #3967
  static MapaFase1 + #673, #3967
  static MapaFase1 + #674, #3967
  static MapaFase1 + #675, #3967
  static MapaFase1 + #676, #3967
  static MapaFase1 + #677, #3967
  static MapaFase1 + #678, #3967
  static MapaFase1 + #679, #3967

  ;Linha 17
  static MapaFase1 + #680, #3967
  static MapaFase1 + #681, #3967
  static MapaFase1 + #682, #3967
  static MapaFase1 + #683, #3967
  static MapaFase1 + #684, #3967
  static MapaFase1 + #685, #3967
  static MapaFase1 + #686, #3967
  static MapaFase1 + #687, #3967
  static MapaFase1 + #688, #3967
  static MapaFase1 + #689, #3967
  static MapaFase1 + #690, #3967
  static MapaFase1 + #691, #3967
  static MapaFase1 + #692, #3967
  static MapaFase1 + #693, #3967
  static MapaFase1 + #694, #3967
  static MapaFase1 + #695, #3967
  static MapaFase1 + #696, #3967
  static MapaFase1 + #697, #3967
  static MapaFase1 + #698, #3967
  static MapaFase1 + #699, #3967
  static MapaFase1 + #700, #3967
  static MapaFase1 + #701, #3967
  static MapaFase1 + #702, #3967
  static MapaFase1 + #703, #3967
  static MapaFase1 + #704, #3967
  static MapaFase1 + #705, #3967
  static MapaFase1 + #706, #3967
  static MapaFase1 + #707, #3967
  static MapaFase1 + #708, #3967
  static MapaFase1 + #709, #3967
  static MapaFase1 + #710, #3967
  static MapaFase1 + #711, #3967
  static MapaFase1 + #712, #3967
  static MapaFase1 + #713, #3967
  static MapaFase1 + #714, #3967
  static MapaFase1 + #715, #3967
  static MapaFase1 + #716, #3967
  static MapaFase1 + #717, #3967
  static MapaFase1 + #718, #3967
  static MapaFase1 + #719, #3967

  ;Linha 18
  static MapaFase1 + #720, #3967
  static MapaFase1 + #721, #3967
  static MapaFase1 + #722, #3967
  static MapaFase1 + #723, #3967
  static MapaFase1 + #724, #3967
  static MapaFase1 + #725, #3967
  static MapaFase1 + #726, #3967
  static MapaFase1 + #727, #3967
  static MapaFase1 + #728, #3967
  static MapaFase1 + #729, #3967
  static MapaFase1 + #730, #3967
  static MapaFase1 + #731, #3967
  static MapaFase1 + #732, #3967
  static MapaFase1 + #733, #3967
  static MapaFase1 + #734, #3967
  static MapaFase1 + #735, #3967
  static MapaFase1 + #736, #3967
  static MapaFase1 + #737, #3967
  static MapaFase1 + #738, #3967
  static MapaFase1 + #739, #3967
  static MapaFase1 + #740, #3967
  static MapaFase1 + #741, #3967
  static MapaFase1 + #742, #3967
  static MapaFase1 + #743, #3967
  static MapaFase1 + #744, #3967
  static MapaFase1 + #745, #3967
  static MapaFase1 + #746, #3967
  static MapaFase1 + #747, #3967
  static MapaFase1 + #748, #3967
  static MapaFase1 + #749, #3967
  static MapaFase1 + #750, #3967
  static MapaFase1 + #751, #3967
  static MapaFase1 + #752, #3967
  static MapaFase1 + #753, #3967
  static MapaFase1 + #754, #3967
  static MapaFase1 + #755, #3967
  static MapaFase1 + #756, #3967
  static MapaFase1 + #757, #3967
  static MapaFase1 + #758, #3967
  static MapaFase1 + #759, #3967

  ;Linha 19
  static MapaFase1 + #760, #3967
  static MapaFase1 + #761, #3967
  static MapaFase1 + #762, #3967
  static MapaFase1 + #763, #3967
  static MapaFase1 + #764, #3967
  static MapaFase1 + #765, #3967
  static MapaFase1 + #766, #3967
  static MapaFase1 + #767, #3967
  static MapaFase1 + #768, #3967
  static MapaFase1 + #769, #3967
  static MapaFase1 + #770, #3967
  static MapaFase1 + #771, #3967
  static MapaFase1 + #772, #3967
  static MapaFase1 + #773, #3967
  static MapaFase1 + #774, #3967
  static MapaFase1 + #775, #3904
  static MapaFase1 + #776, #3967
  static MapaFase1 + #777, #3967
  static MapaFase1 + #778, #3967
  static MapaFase1 + #779, #3967
  static MapaFase1 + #780, #3967
  static MapaFase1 + #781, #3967
  static MapaFase1 + #782, #3967
  static MapaFase1 + #783, #3967
  static MapaFase1 + #784, #3967
  static MapaFase1 + #785, #3967
  static MapaFase1 + #786, #3967
  static MapaFase1 + #787, #3967
  static MapaFase1 + #788, #3967
  static MapaFase1 + #789, #3967
  static MapaFase1 + #790, #3967
  static MapaFase1 + #791, #3967
  static MapaFase1 + #792, #3967
  static MapaFase1 + #793, #1067
  static MapaFase1 + #794, #3967
  static MapaFase1 + #795, #3967
  static MapaFase1 + #796, #3967
  static MapaFase1 + #797, #3967
  static MapaFase1 + #798, #3967
  static MapaFase1 + #799, #3967

  ;Linha 20
  static MapaFase1 + #800, #3967
  static MapaFase1 + #801, #3967
  static MapaFase1 + #802, #3967
  static MapaFase1 + #803, #3967
  static MapaFase1 + #804, #3967
  static MapaFase1 + #805, #3967
  static MapaFase1 + #806, #3967
  static MapaFase1 + #807, #3967
  static MapaFase1 + #808, #3967
  static MapaFase1 + #809, #3967
  static MapaFase1 + #810, #3967
  static MapaFase1 + #811, #3967
  static MapaFase1 + #812, #3967
  static MapaFase1 + #813, #3967
  static MapaFase1 + #814, #3967
  static MapaFase1 + #815, #1066
  static MapaFase1 + #816, #3967
  static MapaFase1 + #817, #3967
  static MapaFase1 + #818, #3967
  static MapaFase1 + #819, #3967
  static MapaFase1 + #820, #3967
  static MapaFase1 + #821, #3967
  static MapaFase1 + #822, #3967
  static MapaFase1 + #823, #3967
  static MapaFase1 + #824, #3967
  static MapaFase1 + #825, #3967
  static MapaFase1 + #826, #3967
  static MapaFase1 + #827, #3967
  static MapaFase1 + #828, #3967
  static MapaFase1 + #829, #3967
  static MapaFase1 + #830, #3967
  static MapaFase1 + #831, #3967
  static MapaFase1 + #832, #3967
  static MapaFase1 + #833, #3967
  static MapaFase1 + #834, #3967
  static MapaFase1 + #835, #3967
  static MapaFase1 + #836, #3967
  static MapaFase1 + #837, #3967
  static MapaFase1 + #838, #3967
  static MapaFase1 + #839, #3967

  ;Linha 21
  static MapaFase1 + #840, #3967
  static MapaFase1 + #841, #3967
  static MapaFase1 + #842, #3967
  static MapaFase1 + #843, #3967
  static MapaFase1 + #844, #3967
  static MapaFase1 + #845, #3967
  static MapaFase1 + #846, #3967
  static MapaFase1 + #847, #3967
  static MapaFase1 + #848, #3967
  static MapaFase1 + #849, #3967
  static MapaFase1 + #850, #3967
  static MapaFase1 + #851, #3967
  static MapaFase1 + #852, #3967
  static MapaFase1 + #853, #3967
  static MapaFase1 + #854, #3967
  static MapaFase1 + #855, #3967
  static MapaFase1 + #856, #3967
  static MapaFase1 + #857, #3967
  static MapaFase1 + #858, #3967
  static MapaFase1 + #859, #3967
  static MapaFase1 + #860, #3967
  static MapaFase1 + #861, #3967
  static MapaFase1 + #862, #3967
  static MapaFase1 + #863, #3967
  static MapaFase1 + #864, #3967
  static MapaFase1 + #865, #3967
  static MapaFase1 + #866, #3967
  static MapaFase1 + #867, #3967
  static MapaFase1 + #868, #3967
  static MapaFase1 + #869, #3967
  static MapaFase1 + #870, #3967
  static MapaFase1 + #871, #3967
  static MapaFase1 + #872, #3967
  static MapaFase1 + #873, #3967
  static MapaFase1 + #874, #3967
  static MapaFase1 + #875, #3967
  static MapaFase1 + #876, #3967
  static MapaFase1 + #877, #3967
  static MapaFase1 + #878, #3967
  static MapaFase1 + #879, #3967

  ;Linha 22
  static MapaFase1 + #880, #3967
  static MapaFase1 + #881, #3967
  static MapaFase1 + #882, #3967
  static MapaFase1 + #883, #3967
  static MapaFase1 + #884, #3967
  static MapaFase1 + #885, #3967
  static MapaFase1 + #886, #3967
  static MapaFase1 + #887, #3967
  static MapaFase1 + #888, #3967
  static MapaFase1 + #889, #3967
  static MapaFase1 + #890, #3967
  static MapaFase1 + #891, #3967
  static MapaFase1 + #892, #3967
  static MapaFase1 + #893, #3967
  static MapaFase1 + #894, #3967
  static MapaFase1 + #895, #3967
  static MapaFase1 + #896, #3967
  static MapaFase1 + #897, #3967
  static MapaFase1 + #898, #3967
  static MapaFase1 + #899, #3967
  static MapaFase1 + #900, #3967
  static MapaFase1 + #901, #3967
  static MapaFase1 + #902, #3967
  static MapaFase1 + #903, #3967
  static MapaFase1 + #904, #3967
  static MapaFase1 + #905, #3967
  static MapaFase1 + #906, #3967
  static MapaFase1 + #907, #3967
  static MapaFase1 + #908, #3967
  static MapaFase1 + #909, #3967
  static MapaFase1 + #910, #3967
  static MapaFase1 + #911, #3967
  static MapaFase1 + #912, #3967
  static MapaFase1 + #913, #3967
  static MapaFase1 + #914, #3967
  static MapaFase1 + #915, #3967
  static MapaFase1 + #916, #3967
  static MapaFase1 + #917, #3967
  static MapaFase1 + #918, #3967
  static MapaFase1 + #919, #3967

  ;Linha 23
  static MapaFase1 + #920, #3967
  static MapaFase1 + #921, #3967
  static MapaFase1 + #922, #3967
  static MapaFase1 + #923, #3967
  static MapaFase1 + #924, #3967
  static MapaFase1 + #925, #3967
  static MapaFase1 + #926, #3967
  static MapaFase1 + #927, #3967
  static MapaFase1 + #928, #3967
  static MapaFase1 + #929, #3967
  static MapaFase1 + #930, #3967
  static MapaFase1 + #931, #3967
  static MapaFase1 + #932, #3967
  static MapaFase1 + #933, #3967
  static MapaFase1 + #934, #3967
  static MapaFase1 + #935, #3967
  static MapaFase1 + #936, #3967
  static MapaFase1 + #937, #3967
  static MapaFase1 + #938, #3967
  static MapaFase1 + #939, #3967
  static MapaFase1 + #940, #3967
  static MapaFase1 + #941, #3967
  static MapaFase1 + #942, #3967
  static MapaFase1 + #943, #3967
  static MapaFase1 + #944, #3967
  static MapaFase1 + #945, #3967
  static MapaFase1 + #946, #3967
  static MapaFase1 + #947, #3967
  static MapaFase1 + #948, #3967
  static MapaFase1 + #949, #3967
  static MapaFase1 + #950, #3967
  static MapaFase1 + #951, #3967
  static MapaFase1 + #952, #3967
  static MapaFase1 + #953, #3967
  static MapaFase1 + #954, #3967
  static MapaFase1 + #955, #3967
  static MapaFase1 + #956, #3967
  static MapaFase1 + #957, #3967
  static MapaFase1 + #958, #3967
  static MapaFase1 + #959, #3967

  ;Linha 24
  static MapaFase1 + #960, #1067
  static MapaFase1 + #961, #3967
  static MapaFase1 + #962, #3967
  static MapaFase1 + #963, #3967
  static MapaFase1 + #964, #3967
  static MapaFase1 + #965, #3967
  static MapaFase1 + #966, #3967
  static MapaFase1 + #967, #3967
  static MapaFase1 + #968, #3967
  static MapaFase1 + #969, #3967
  static MapaFase1 + #970, #3967
  static MapaFase1 + #971, #3967
  static MapaFase1 + #972, #3967
  static MapaFase1 + #973, #3967
  static MapaFase1 + #974, #3967
  static MapaFase1 + #975, #3967
  static MapaFase1 + #976, #3967
  static MapaFase1 + #977, #3967
  static MapaFase1 + #978, #3967
  static MapaFase1 + #979, #3967
  static MapaFase1 + #980, #3967
  static MapaFase1 + #981, #3967
  static MapaFase1 + #982, #3967
  static MapaFase1 + #983, #3967
  static MapaFase1 + #984, #3967
  static MapaFase1 + #985, #3967
  static MapaFase1 + #986, #3967
  static MapaFase1 + #987, #3967
  static MapaFase1 + #988, #3967
  static MapaFase1 + #989, #3967
  static MapaFase1 + #990, #3967
  static MapaFase1 + #991, #3967
  static MapaFase1 + #992, #3967
  static MapaFase1 + #993, #3967
  static MapaFase1 + #994, #3967
  static MapaFase1 + #995, #3967
  static MapaFase1 + #996, #3967
  static MapaFase1 + #997, #3967
  static MapaFase1 + #998, #3967
  static MapaFase1 + #999, #3967

  ;Linha 25
  static MapaFase1 + #1000, #3967
  static MapaFase1 + #1001, #3967
  static MapaFase1 + #1002, #3967
  static MapaFase1 + #1003, #3967
  static MapaFase1 + #1004, #3967
  static MapaFase1 + #1005, #3967
  static MapaFase1 + #1006, #3967
  static MapaFase1 + #1007, #3967
  static MapaFase1 + #1008, #3967
  static MapaFase1 + #1009, #3967
  static MapaFase1 + #1010, #3967
  static MapaFase1 + #1011, #3967
  static MapaFase1 + #1012, #3967
  static MapaFase1 + #1013, #3967
  static MapaFase1 + #1014, #3967
  static MapaFase1 + #1015, #3967
  static MapaFase1 + #1016, #3967
  static MapaFase1 + #1017, #3967
  static MapaFase1 + #1018, #3967
  static MapaFase1 + #1019, #3967
  static MapaFase1 + #1020, #3967
  static MapaFase1 + #1021, #3967
  static MapaFase1 + #1022, #3967
  static MapaFase1 + #1023, #3967
  static MapaFase1 + #1024, #3967
  static MapaFase1 + #1025, #3967
  static MapaFase1 + #1026, #3967
  static MapaFase1 + #1027, #3967
  static MapaFase1 + #1028, #3967
  static MapaFase1 + #1029, #3967
  static MapaFase1 + #1030, #3967
  static MapaFase1 + #1031, #3967
  static MapaFase1 + #1032, #3967
  static MapaFase1 + #1033, #3967
  static MapaFase1 + #1034, #3967
  static MapaFase1 + #1035, #3967
  static MapaFase1 + #1036, #3967
  static MapaFase1 + #1037, #3967
  static MapaFase1 + #1038, #3967
  static MapaFase1 + #1039, #3967

  ;Linha 26
  static MapaFase1 + #1040, #3967
  static MapaFase1 + #1041, #3967
  static MapaFase1 + #1042, #3967
  static MapaFase1 + #1043, #3967
  static MapaFase1 + #1044, #3967
  static MapaFase1 + #1045, #3967
  static MapaFase1 + #1046, #3967
  static MapaFase1 + #1047, #3967
  static MapaFase1 + #1048, #3967
  static MapaFase1 + #1049, #3967
  static MapaFase1 + #1050, #3967
  static MapaFase1 + #1051, #3967
  static MapaFase1 + #1052, #3967
  static MapaFase1 + #1053, #3967
  static MapaFase1 + #1054, #3967
  static MapaFase1 + #1055, #3967
  static MapaFase1 + #1056, #3967
  static MapaFase1 + #1057, #3967
  static MapaFase1 + #1058, #3967
  static MapaFase1 + #1059, #3967
  static MapaFase1 + #1060, #3967
  static MapaFase1 + #1061, #3967
  static MapaFase1 + #1062, #3967
  static MapaFase1 + #1063, #3967
  static MapaFase1 + #1064, #3967
  static MapaFase1 + #1065, #3967
  static MapaFase1 + #1066, #3967
  static MapaFase1 + #1067, #3967
  static MapaFase1 + #1068, #1088
  static MapaFase1 + #1069, #3967
  static MapaFase1 + #1070, #3967
  static MapaFase1 + #1071, #3967
  static MapaFase1 + #1072, #3967
  static MapaFase1 + #1073, #3967
  static MapaFase1 + #1074, #3967
  static MapaFase1 + #1075, #3967
  static MapaFase1 + #1076, #3967
  static MapaFase1 + #1077, #3967
  static MapaFase1 + #1078, #3967
  static MapaFase1 + #1079, #3967

  ;Linha 27
  static MapaFase1 + #1080, #3967
  static MapaFase1 + #1081, #3967
  static MapaFase1 + #1082, #3967
  static MapaFase1 + #1083, #3967
  static MapaFase1 + #1084, #3967
  static MapaFase1 + #1085, #3967
  static MapaFase1 + #1086, #3967
  static MapaFase1 + #1087, #3967
  static MapaFase1 + #1088, #3967
  static MapaFase1 + #1089, #3967
  static MapaFase1 + #1090, #3967
  static MapaFase1 + #1091, #3967
  static MapaFase1 + #1092, #3967
  static MapaFase1 + #1093, #3967
  static MapaFase1 + #1094, #3967
  static MapaFase1 + #1095, #3967
  static MapaFase1 + #1096, #3967
  static MapaFase1 + #1097, #3967
  static MapaFase1 + #1098, #3967
  static MapaFase1 + #1099, #3967
  static MapaFase1 + #1100, #3967
  static MapaFase1 + #1101, #3967
  static MapaFase1 + #1102, #3967
  static MapaFase1 + #1103, #3967
  static MapaFase1 + #1104, #3967
  static MapaFase1 + #1105, #3967
  static MapaFase1 + #1106, #3967
  static MapaFase1 + #1107, #3967
  static MapaFase1 + #1108, #3967
  static MapaFase1 + #1109, #3967
  static MapaFase1 + #1110, #3967
  static MapaFase1 + #1111, #3967
  static MapaFase1 + #1112, #3967
  static MapaFase1 + #1113, #3967
  static MapaFase1 + #1114, #3967
  static MapaFase1 + #1115, #3967
  static MapaFase1 + #1116, #3967
  static MapaFase1 + #1117, #3967
  static MapaFase1 + #1118, #3967
  static MapaFase1 + #1119, #3967

  ;Linha 28
  static MapaFase1 + #1120, #3967
  static MapaFase1 + #1121, #3967
  static MapaFase1 + #1122, #3967
  static MapaFase1 + #1123, #3967
  static MapaFase1 + #1124, #3967
  static MapaFase1 + #1125, #3967
  static MapaFase1 + #1126, #3967
  static MapaFase1 + #1127, #3967
  static MapaFase1 + #1128, #3967
  static MapaFase1 + #1129, #3967
  static MapaFase1 + #1130, #3967
  static MapaFase1 + #1131, #3967
  static MapaFase1 + #1132, #3967
  static MapaFase1 + #1133, #3967
  static MapaFase1 + #1134, #3967
  static MapaFase1 + #1135, #3967
  static MapaFase1 + #1136, #3967
  static MapaFase1 + #1137, #3967
  static MapaFase1 + #1138, #3967
  static MapaFase1 + #1139, #3967
  static MapaFase1 + #1140, #3967
  static MapaFase1 + #1141, #3967
  static MapaFase1 + #1142, #3967
  static MapaFase1 + #1143, #3967
  static MapaFase1 + #1144, #3967
  static MapaFase1 + #1145, #3967
  static MapaFase1 + #1146, #3967
  static MapaFase1 + #1147, #3967
  static MapaFase1 + #1148, #3967
  static MapaFase1 + #1149, #3967
  static MapaFase1 + #1150, #3967
  static MapaFase1 + #1151, #3967
  static MapaFase1 + #1152, #3967
  static MapaFase1 + #1153, #3967
  static MapaFase1 + #1154, #3967
  static MapaFase1 + #1155, #3967
  static MapaFase1 + #1156, #3967
  static MapaFase1 + #1157, #3967
  static MapaFase1 + #1158, #3967
  static MapaFase1 + #1159, #3967

  ;Linha 29
  static MapaFase1 + #1160, #3967
  static MapaFase1 + #1161, #3967
  static MapaFase1 + #1162, #3967
  static MapaFase1 + #1163, #3967
  static MapaFase1 + #1164, #3967
  static MapaFase1 + #1165, #3967
  static MapaFase1 + #1166, #3967
  static MapaFase1 + #1167, #3967
  static MapaFase1 + #1168, #3967
  static MapaFase1 + #1169, #3967
  static MapaFase1 + #1170, #3967
  static MapaFase1 + #1171, #3967
  static MapaFase1 + #1172, #3967
  static MapaFase1 + #1173, #3967
  static MapaFase1 + #1174, #3967
  static MapaFase1 + #1175, #3967
  static MapaFase1 + #1176, #3967
  static MapaFase1 + #1177, #3967
  static MapaFase1 + #1178, #3967
  static MapaFase1 + #1179, #3967
  static MapaFase1 + #1180, #3967
  static MapaFase1 + #1181, #3967
  static MapaFase1 + #1182, #3967
  static MapaFase1 + #1183, #3967
  static MapaFase1 + #1184, #3967
  static MapaFase1 + #1185, #3967
  static MapaFase1 + #1186, #3967
  static MapaFase1 + #1187, #3967
  static MapaFase1 + #1188, #3967
  static MapaFase1 + #1189, #3967
  static MapaFase1 + #1190, #3967
  static MapaFase1 + #1191, #3967
  static MapaFase1 + #1192, #3967
  static MapaFase1 + #1193, #3967
  static MapaFase1 + #1194, #3967
  static MapaFase1 + #1195, #3967
  static MapaFase1 + #1196, #3967
  static MapaFase1 + #1197, #3967
  static MapaFase1 + #1198, #3967
  static MapaFase1 + #1199, #3967

MapaFase2 : var #1200
  ;Linha 0
  static MapaFase2 + #0, #3967
  static MapaFase2 + #1, #3967
  static MapaFase2 + #2, #3967
  static MapaFase2 + #3, #3967
  static MapaFase2 + #4, #3967
  static MapaFase2 + #5, #3967
  static MapaFase2 + #6, #3967
  static MapaFase2 + #7, #3967
  static MapaFase2 + #8, #3967
  static MapaFase2 + #9, #3967
  static MapaFase2 + #10, #3967
  static MapaFase2 + #11, #3967
  static MapaFase2 + #12, #3967
  static MapaFase2 + #13, #3967
  static MapaFase2 + #14, #3967
  static MapaFase2 + #15, #3967
  static MapaFase2 + #16, #3967
  static MapaFase2 + #17, #3967
  static MapaFase2 + #18, #3967
  static MapaFase2 + #19, #3967
  static MapaFase2 + #20, #3967
  static MapaFase2 + #21, #3967
  static MapaFase2 + #22, #3967
  static MapaFase2 + #23, #3967
  static MapaFase2 + #24, #3967
  static MapaFase2 + #25, #3967
  static MapaFase2 + #26, #3967
  static MapaFase2 + #27, #3967
  static MapaFase2 + #28, #0
  static MapaFase2 + #29, #3967
  static MapaFase2 + #30, #3967
  static MapaFase2 + #31, #3967
  static MapaFase2 + #32, #3967
  static MapaFase2 + #33, #3967
  static MapaFase2 + #34, #3967
  static MapaFase2 + #35, #3967
  static MapaFase2 + #36, #3967
  static MapaFase2 + #37, #3967
  static MapaFase2 + #38, #3967
  static MapaFase2 + #39, #3967

  ;Linha 1
  static MapaFase2 + #40, #3967
  static MapaFase2 + #41, #3967
  static MapaFase2 + #42, #3967
  static MapaFase2 + #43, #3967
  static MapaFase2 + #44, #3967
  static MapaFase2 + #45, #3967
  static MapaFase2 + #46, #3967
  static MapaFase2 + #47, #3967
  static MapaFase2 + #48, #3967
  static MapaFase2 + #49, #3967
  static MapaFase2 + #50, #3967
  static MapaFase2 + #51, #3967
  static MapaFase2 + #52, #3967
  static MapaFase2 + #53, #3967
  static MapaFase2 + #54, #3967
  static MapaFase2 + #55, #3967
  static MapaFase2 + #56, #3967
  static MapaFase2 + #57, #3967
  static MapaFase2 + #58, #3967
  static MapaFase2 + #59, #3967
  static MapaFase2 + #60, #3967
  static MapaFase2 + #61, #3967
  static MapaFase2 + #62, #3967
  static MapaFase2 + #63, #3967
  static MapaFase2 + #64, #3967
  static MapaFase2 + #65, #3967
  static MapaFase2 + #66, #3967
  static MapaFase2 + #67, #3967
  static MapaFase2 + #68, #0
  static MapaFase2 + #69, #3967
  static MapaFase2 + #70, #3967
  static MapaFase2 + #71, #3967
  static MapaFase2 + #72, #3967
  static MapaFase2 + #73, #3967
  static MapaFase2 + #74, #3878
  static MapaFase2 + #75, #3878
  static MapaFase2 + #76, #3878
  static MapaFase2 + #77, #3967
  static MapaFase2 + #78, #3967
  static MapaFase2 + #79, #3967

  ;Linha 2
  static MapaFase2 + #80, #3967
  static MapaFase2 + #81, #3967
  static MapaFase2 + #82, #3967
  static MapaFase2 + #83, #3967
  static MapaFase2 + #84, #3967
  static MapaFase2 + #85, #3967
  static MapaFase2 + #86, #3967
  static MapaFase2 + #87, #3967
  static MapaFase2 + #88, #3967
  static MapaFase2 + #89, #3967
  static MapaFase2 + #90, #3967
  static MapaFase2 + #91, #3967
  static MapaFase2 + #92, #3967
  static MapaFase2 + #93, #3967
  static MapaFase2 + #94, #3967
  static MapaFase2 + #95, #3967
  static MapaFase2 + #96, #3967
  static MapaFase2 + #97, #3967
  static MapaFase2 + #98, #3967
  static MapaFase2 + #99, #3967
  static MapaFase2 + #100, #3967
  static MapaFase2 + #101, #3967
  static MapaFase2 + #102, #3967
  static MapaFase2 + #103, #3967
  static MapaFase2 + #104, #3967
  static MapaFase2 + #105, #3967
  static MapaFase2 + #106, #3967
  static MapaFase2 + #107, #3967
  static MapaFase2 + #108, #3967
  static MapaFase2 + #109, #3967
  static MapaFase2 + #110, #3967
  static MapaFase2 + #111, #3967
  static MapaFase2 + #112, #3967
  static MapaFase2 + #113, #3967
  static MapaFase2 + #114, #3878
  static MapaFase2 + #115, #3878
  static MapaFase2 + #116, #3878
  static MapaFase2 + #117, #3967
  static MapaFase2 + #118, #1066
  static MapaFase2 + #119, #3967

  ;Linha 3
  static MapaFase2 + #120, #3967
  static MapaFase2 + #121, #3967
  static MapaFase2 + #122, #3967
  static MapaFase2 + #123, #3967
  static MapaFase2 + #124, #3967
  static MapaFase2 + #125, #3967
  static MapaFase2 + #126, #3967
  static MapaFase2 + #127, #3967
  static MapaFase2 + #128, #3967
  static MapaFase2 + #129, #3967
  static MapaFase2 + #130, #3967
  static MapaFase2 + #131, #3967
  static MapaFase2 + #132, #3967
  static MapaFase2 + #133, #3967
  static MapaFase2 + #134, #3967
  static MapaFase2 + #135, #3967
  static MapaFase2 + #136, #3967
  static MapaFase2 + #137, #3967
  static MapaFase2 + #138, #3967
  static MapaFase2 + #139, #3967
  static MapaFase2 + #140, #3967
  static MapaFase2 + #141, #3967
  static MapaFase2 + #142, #3967
  static MapaFase2 + #143, #3967
  static MapaFase2 + #144, #3967
  static MapaFase2 + #145, #3967
  static MapaFase2 + #146, #3967
  static MapaFase2 + #147, #3967
  static MapaFase2 + #148, #3967
  static MapaFase2 + #149, #3967
  static MapaFase2 + #150, #3967
  static MapaFase2 + #151, #3967
  static MapaFase2 + #152, #3967
  static MapaFase2 + #153, #3967
  static MapaFase2 + #154, #3878
  static MapaFase2 + #155, #3878
  static MapaFase2 + #156, #3878
  static MapaFase2 + #157, #3967
  static MapaFase2 + #158, #3967
  static MapaFase2 + #159, #3967

  ;Linha 4
  static MapaFase2 + #160, #3967
  static MapaFase2 + #161, #3967
  static MapaFase2 + #162, #3967
  static MapaFase2 + #163, #3967
  static MapaFase2 + #164, #3967
  static MapaFase2 + #165, #3967
  static MapaFase2 + #166, #3967
  static MapaFase2 + #167, #3967
  static MapaFase2 + #168, #3967
  static MapaFase2 + #169, #3967
  static MapaFase2 + #170, #3967
  static MapaFase2 + #171, #3967
  static MapaFase2 + #172, #3967
  static MapaFase2 + #173, #3967
  static MapaFase2 + #174, #3967
  static MapaFase2 + #175, #3967
  static MapaFase2 + #176, #3967
  static MapaFase2 + #177, #3967
  static MapaFase2 + #178, #3967
  static MapaFase2 + #179, #3967
  static MapaFase2 + #180, #3967
  static MapaFase2 + #181, #3967
  static MapaFase2 + #182, #3967
  static MapaFase2 + #183, #3967
  static MapaFase2 + #184, #3967
  static MapaFase2 + #185, #3967
  static MapaFase2 + #186, #3967
  static MapaFase2 + #187, #3967
  static MapaFase2 + #188, #3967
  static MapaFase2 + #189, #3967
  static MapaFase2 + #190, #3967
  static MapaFase2 + #191, #3870
  static MapaFase2 + #192, #3876
  static MapaFase2 + #193, #3876
  static MapaFase2 + #194, #3967
  static MapaFase2 + #195, #3967
  static MapaFase2 + #196, #3967
  static MapaFase2 + #197, #3967
  static MapaFase2 + #198, #3967
  static MapaFase2 + #199, #3967

  ;Linha 5
  static MapaFase2 + #200, #3967
  static MapaFase2 + #201, #3967
  static MapaFase2 + #202, #3967
  static MapaFase2 + #203, #3967
  static MapaFase2 + #204, #1088
  static MapaFase2 + #205, #3967
  static MapaFase2 + #206, #3967
  static MapaFase2 + #207, #3967
  static MapaFase2 + #208, #3967
  static MapaFase2 + #209, #3967
  static MapaFase2 + #210, #3967
  static MapaFase2 + #211, #3967
  static MapaFase2 + #212, #3967
  static MapaFase2 + #213, #3967
  static MapaFase2 + #214, #3967
  static MapaFase2 + #215, #3967
  static MapaFase2 + #216, #3967
  static MapaFase2 + #217, #3967
  static MapaFase2 + #218, #3967
  static MapaFase2 + #219, #3967
  static MapaFase2 + #220, #3967
  static MapaFase2 + #221, #3967
  static MapaFase2 + #222, #3967
  static MapaFase2 + #223, #3967
  static MapaFase2 + #224, #3967
  static MapaFase2 + #225, #3967
  static MapaFase2 + #226, #3967
  static MapaFase2 + #227, #3967
  static MapaFase2 + #228, #3967
  static MapaFase2 + #229, #3967
  static MapaFase2 + #230, #1793
  static MapaFase2 + #231, #1828
  static MapaFase2 + #232, #1828
  static MapaFase2 + #233, #1828
  static MapaFase2 + #234, #1829
  static MapaFase2 + #235, #3967
  static MapaFase2 + #236, #3967
  static MapaFase2 + #237, #3967
  static MapaFase2 + #238, #3967
  static MapaFase2 + #239, #3967

  ;Linha 6
  static MapaFase2 + #240, #3967
  static MapaFase2 + #241, #3967
  static MapaFase2 + #242, #3967
  static MapaFase2 + #243, #3967
  static MapaFase2 + #244, #3967
  static MapaFase2 + #245, #3967
  static MapaFase2 + #246, #3967
  static MapaFase2 + #247, #3967
  static MapaFase2 + #248, #3967
  static MapaFase2 + #249, #3967
  static MapaFase2 + #250, #3967
  static MapaFase2 + #251, #3967
  static MapaFase2 + #252, #3967
  static MapaFase2 + #253, #3967
  static MapaFase2 + #254, #3967
  static MapaFase2 + #255, #3967
  static MapaFase2 + #256, #3967
  static MapaFase2 + #257, #3967
  static MapaFase2 + #258, #3967
  static MapaFase2 + #259, #3967
  static MapaFase2 + #260, #3967
  static MapaFase2 + #261, #3967
  static MapaFase2 + #262, #3967
  static MapaFase2 + #263, #3967
  static MapaFase2 + #264, #3967
  static MapaFase2 + #265, #3967
  static MapaFase2 + #266, #3967
  static MapaFase2 + #267, #3967
  static MapaFase2 + #268, #3899
  static MapaFase2 + #269, #1793
  static MapaFase2 + #270, #1822
  static MapaFase2 + #271, #1818
  static MapaFase2 + #272, #1820
  static MapaFase2 + #273, #1828
  static MapaFase2 + #274, #1828
  static MapaFase2 + #275, #1829
  static MapaFase2 + #276, #3967
  static MapaFase2 + #277, #3967
  static MapaFase2 + #278, #3967
  static MapaFase2 + #279, #3967

  ;Linha 7
  static MapaFase2 + #280, #3967
  static MapaFase2 + #281, #3967
  static MapaFase2 + #282, #3967
  static MapaFase2 + #283, #3967
  static MapaFase2 + #284, #3967
  static MapaFase2 + #285, #3967
  static MapaFase2 + #286, #3967
  static MapaFase2 + #287, #3967
  static MapaFase2 + #288, #3967
  static MapaFase2 + #289, #3967
  static MapaFase2 + #290, #3967
  static MapaFase2 + #291, #3967
  static MapaFase2 + #292, #3967
  static MapaFase2 + #293, #3967
  static MapaFase2 + #294, #3967
  static MapaFase2 + #295, #3967
  static MapaFase2 + #296, #3967
  static MapaFase2 + #297, #3967
  static MapaFase2 + #298, #3967
  static MapaFase2 + #299, #3967
  static MapaFase2 + #300, #3967
  static MapaFase2 + #301, #3967
  static MapaFase2 + #302, #3967
  static MapaFase2 + #303, #3967
  static MapaFase2 + #304, #3967
  static MapaFase2 + #305, #3967
  static MapaFase2 + #306, #3967
  static MapaFase2 + #307, #3967
  static MapaFase2 + #308, #3967
  static MapaFase2 + #309, #1828
  static MapaFase2 + #310, #1821
  static MapaFase2 + #311, #1915
  static MapaFase2 + #312, #1819
  static MapaFase2 + #313, #1828
  static MapaFase2 + #314, #1828
  static MapaFase2 + #315, #1828
  static MapaFase2 + #316, #3967
  static MapaFase2 + #317, #3967
  static MapaFase2 + #318, #3967
  static MapaFase2 + #319, #3967

  ;Linha 8
  static MapaFase2 + #320, #3967
  static MapaFase2 + #321, #3967
  static MapaFase2 + #322, #3967
  static MapaFase2 + #323, #3967
  static MapaFase2 + #324, #3967
  static MapaFase2 + #325, #3967
  static MapaFase2 + #326, #3967
  static MapaFase2 + #327, #3967
  static MapaFase2 + #328, #3967
  static MapaFase2 + #329, #3967
  static MapaFase2 + #330, #3967
  static MapaFase2 + #331, #3967
  static MapaFase2 + #332, #3967
  static MapaFase2 + #333, #3967
  static MapaFase2 + #334, #3967
  static MapaFase2 + #335, #3967
  static MapaFase2 + #336, #3967
  static MapaFase2 + #337, #3967
  static MapaFase2 + #338, #3967
  static MapaFase2 + #339, #3967
  static MapaFase2 + #340, #3967
  static MapaFase2 + #341, #3967
  static MapaFase2 + #342, #3967
  static MapaFase2 + #343, #3967
  static MapaFase2 + #344, #3967
  static MapaFase2 + #345, #3967
  static MapaFase2 + #346, #3967
  static MapaFase2 + #347, #3967
  static MapaFase2 + #348, #3876
  static MapaFase2 + #349, #1817
  static MapaFase2 + #350, #1817
  static MapaFase2 + #351, #1817
  static MapaFase2 + #352, #1817
  static MapaFase2 + #353, #1817
  static MapaFase2 + #354, #1817
  static MapaFase2 + #355, #1817
  static MapaFase2 + #356, #3876
  static MapaFase2 + #357, #3967
  static MapaFase2 + #358, #3967
  static MapaFase2 + #359, #3967

  ;Linha 9
  static MapaFase2 + #360, #3967
  static MapaFase2 + #361, #3967
  static MapaFase2 + #362, #3967
  static MapaFase2 + #363, #3967
  static MapaFase2 + #364, #3967
  static MapaFase2 + #365, #3967
  static MapaFase2 + #366, #3967
  static MapaFase2 + #367, #3967
  static MapaFase2 + #368, #3967
  static MapaFase2 + #369, #3967
  static MapaFase2 + #370, #3967
  static MapaFase2 + #371, #3967
  static MapaFase2 + #372, #1067
  static MapaFase2 + #373, #3967
  static MapaFase2 + #374, #3967
  static MapaFase2 + #375, #3967
  static MapaFase2 + #376, #3967
  static MapaFase2 + #377, #3967
  static MapaFase2 + #378, #3967
  static MapaFase2 + #379, #3967
  static MapaFase2 + #380, #3967
  static MapaFase2 + #381, #3967
  static MapaFase2 + #382, #3967
  static MapaFase2 + #383, #3904
  static MapaFase2 + #384, #1067
  static MapaFase2 + #385, #3967
  static MapaFase2 + #386, #3967
  static MapaFase2 + #387, #3967
  static MapaFase2 + #388, #3967
  static MapaFase2 + #389, #1828
  static MapaFase2 + #390, #1828
  static MapaFase2 + #391, #1828
  static MapaFase2 + #392, #1828
  static MapaFase2 + #393, #1828
  static MapaFase2 + #394, #1828
  static MapaFase2 + #395, #1828
  static MapaFase2 + #396, #3967
  static MapaFase2 + #397, #3967
  static MapaFase2 + #398, #3967
  static MapaFase2 + #399, #3967

  ;Linha 10
  static MapaFase2 + #400, #3967
  static MapaFase2 + #401, #3967
  static MapaFase2 + #402, #3967
  static MapaFase2 + #403, #3967
  static MapaFase2 + #404, #3967
  static MapaFase2 + #405, #3967
  static MapaFase2 + #406, #3967
  static MapaFase2 + #407, #3967
  static MapaFase2 + #408, #3967
  static MapaFase2 + #409, #3967
  static MapaFase2 + #410, #3967
  static MapaFase2 + #411, #3967
  static MapaFase2 + #412, #3967
  static MapaFase2 + #413, #3967
  static MapaFase2 + #414, #3967
  static MapaFase2 + #415, #3967
  static MapaFase2 + #416, #3967
  static MapaFase2 + #417, #3967
  static MapaFase2 + #418, #3967
  static MapaFase2 + #419, #3967
  static MapaFase2 + #420, #3967
  static MapaFase2 + #421, #3967
  static MapaFase2 + #422, #3967
  static MapaFase2 + #423, #3967
  static MapaFase2 + #424, #3967
  static MapaFase2 + #425, #3967
  static MapaFase2 + #426, #3967
  static MapaFase2 + #427, #3967
  static MapaFase2 + #428, #3967
  static MapaFase2 + #429, #1823
  static MapaFase2 + #430, #1828
  static MapaFase2 + #431, #1828
  static MapaFase2 + #432, #1828
  static MapaFase2 + #433, #1828
  static MapaFase2 + #434, #1828
  static MapaFase2 + #435, #1851
  static MapaFase2 + #436, #3967
  static MapaFase2 + #437, #3967
  static MapaFase2 + #438, #3967
  static MapaFase2 + #439, #3967

  ;Linha 11
  static MapaFase2 + #440, #3967
  static MapaFase2 + #441, #3967
  static MapaFase2 + #442, #3967
  static MapaFase2 + #443, #3967
  static MapaFase2 + #444, #3967
  static MapaFase2 + #445, #3967
  static MapaFase2 + #446, #3967
  static MapaFase2 + #447, #3967
  static MapaFase2 + #448, #3967
  static MapaFase2 + #449, #3967
  static MapaFase2 + #450, #3967
  static MapaFase2 + #451, #3967
  static MapaFase2 + #452, #3967
  static MapaFase2 + #453, #3967
  static MapaFase2 + #454, #3967
  static MapaFase2 + #455, #3967
  static MapaFase2 + #456, #3967
  static MapaFase2 + #457, #3967
  static MapaFase2 + #458, #3967
  static MapaFase2 + #459, #3967
  static MapaFase2 + #460, #3967
  static MapaFase2 + #461, #3967
  static MapaFase2 + #462, #3967
  static MapaFase2 + #463, #3967
  static MapaFase2 + #464, #3967
  static MapaFase2 + #465, #3967
  static MapaFase2 + #466, #3967
  static MapaFase2 + #467, #3967
  static MapaFase2 + #468, #3967
  static MapaFase2 + #469, #3967
  static MapaFase2 + #470, #1823
  static MapaFase2 + #471, #1828
  static MapaFase2 + #472, #1828
  static MapaFase2 + #473, #1828
  static MapaFase2 + #474, #1851
  static MapaFase2 + #475, #3967
  static MapaFase2 + #476, #3967
  static MapaFase2 + #477, #3967
  static MapaFase2 + #478, #3967
  static MapaFase2 + #479, #3967

  ;Linha 12
  static MapaFase2 + #480, #3967
  static MapaFase2 + #481, #3967
  static MapaFase2 + #482, #3967
  static MapaFase2 + #483, #3967
  static MapaFase2 + #484, #3967
  static MapaFase2 + #485, #3967
  static MapaFase2 + #486, #3967
  static MapaFase2 + #487, #3967
  static MapaFase2 + #488, #3967
  static MapaFase2 + #489, #3967
  static MapaFase2 + #490, #3967
  static MapaFase2 + #491, #3967
  static MapaFase2 + #492, #3967
  static MapaFase2 + #493, #3967
  static MapaFase2 + #494, #3967
  static MapaFase2 + #495, #3967
  static MapaFase2 + #496, #3967
  static MapaFase2 + #497, #3967
  static MapaFase2 + #498, #3967
  static MapaFase2 + #499, #3967
  static MapaFase2 + #500, #3967
  static MapaFase2 + #501, #3967
  static MapaFase2 + #502, #3967
  static MapaFase2 + #503, #3967
  static MapaFase2 + #504, #3967
  static MapaFase2 + #505, #3967
  static MapaFase2 + #506, #3967
  static MapaFase2 + #507, #3967
  static MapaFase2 + #508, #3967
  static MapaFase2 + #509, #3967
  static MapaFase2 + #510, #3967
  static MapaFase2 + #511, #3967
  static MapaFase2 + #512, #3876
  static MapaFase2 + #513, #3967
  static MapaFase2 + #514, #3967
  static MapaFase2 + #515, #3967
  static MapaFase2 + #516, #3967
  static MapaFase2 + #517, #3967
  static MapaFase2 + #518, #3967
  static MapaFase2 + #519, #3967

  ;Linha 13
  static MapaFase2 + #520, #3967
  static MapaFase2 + #521, #3967
  static MapaFase2 + #522, #3967
  static MapaFase2 + #523, #3967
  static MapaFase2 + #524, #3967
  static MapaFase2 + #525, #3967
  static MapaFase2 + #526, #3967
  static MapaFase2 + #527, #3967
  static MapaFase2 + #528, #3967
  static MapaFase2 + #529, #3967
  static MapaFase2 + #530, #3967
  static MapaFase2 + #531, #3967
  static MapaFase2 + #532, #3967
  static MapaFase2 + #533, #3967
  static MapaFase2 + #534, #3967
  static MapaFase2 + #535, #3967
  static MapaFase2 + #536, #3967
  static MapaFase2 + #537, #3967
  static MapaFase2 + #538, #3967
  static MapaFase2 + #539, #3967
  static MapaFase2 + #540, #3967
  static MapaFase2 + #541, #3967
  static MapaFase2 + #542, #3967
  static MapaFase2 + #543, #3967
  static MapaFase2 + #544, #3967
  static MapaFase2 + #545, #3967
  static MapaFase2 + #546, #3967
  static MapaFase2 + #547, #3967
  static MapaFase2 + #548, #3967
  static MapaFase2 + #549, #3967
  static MapaFase2 + #550, #3967
  static MapaFase2 + #551, #3967
  static MapaFase2 + #552, #3967
  static MapaFase2 + #553, #3967
  static MapaFase2 + #554, #3967
  static MapaFase2 + #555, #3967
  static MapaFase2 + #556, #3967
  static MapaFase2 + #557, #3967
  static MapaFase2 + #558, #3967
  static MapaFase2 + #559, #3967

  ;Linha 14
  static MapaFase2 + #560, #3967
  static MapaFase2 + #561, #3967
  static MapaFase2 + #562, #3967
  static MapaFase2 + #563, #3967
  static MapaFase2 + #564, #3967
  static MapaFase2 + #565, #3967
  static MapaFase2 + #566, #3967
  static MapaFase2 + #567, #3967
  static MapaFase2 + #568, #3967
  static MapaFase2 + #569, #3967
  static MapaFase2 + #570, #3967
  static MapaFase2 + #571, #3967
  static MapaFase2 + #572, #3967
  static MapaFase2 + #573, #3967
  static MapaFase2 + #574, #3967
  static MapaFase2 + #575, #3967
  static MapaFase2 + #576, #3967
  static MapaFase2 + #577, #3967
  static MapaFase2 + #578, #3967
  static MapaFase2 + #579, #3967
  static MapaFase2 + #580, #3967
  static MapaFase2 + #581, #3967
  static MapaFase2 + #582, #3967
  static MapaFase2 + #583, #3967
  static MapaFase2 + #584, #3967
  static MapaFase2 + #585, #3967
  static MapaFase2 + #586, #3967
  static MapaFase2 + #587, #3967
  static MapaFase2 + #588, #3967
  static MapaFase2 + #589, #3967
  static MapaFase2 + #590, #3967
  static MapaFase2 + #591, #3967
  static MapaFase2 + #592, #3967
  static MapaFase2 + #593, #3967
  static MapaFase2 + #594, #3967
  static MapaFase2 + #595, #3967
  static MapaFase2 + #596, #3967
  static MapaFase2 + #597, #3967
  static MapaFase2 + #598, #3967
  static MapaFase2 + #599, #3967

  ;Linha 15
  static MapaFase2 + #600, #3967
  static MapaFase2 + #601, #3967
  static MapaFase2 + #602, #3967
  static MapaFase2 + #603, #3967
  static MapaFase2 + #604, #3967
  static MapaFase2 + #605, #3967
  static MapaFase2 + #606, #3967
  static MapaFase2 + #607, #3967
  static MapaFase2 + #608, #3967
  static MapaFase2 + #609, #3967
  static MapaFase2 + #610, #3967
  static MapaFase2 + #611, #3967
  static MapaFase2 + #612, #3967
  static MapaFase2 + #613, #3967
  static MapaFase2 + #614, #3967
  static MapaFase2 + #615, #3967
  static MapaFase2 + #616, #3967
  static MapaFase2 + #617, #3967
  static MapaFase2 + #618, #3967
  static MapaFase2 + #619, #3967
  static MapaFase2 + #620, #3967
  static MapaFase2 + #621, #3967
  static MapaFase2 + #622, #3967
  static MapaFase2 + #623, #3967
  static MapaFase2 + #624, #3967
  static MapaFase2 + #625, #3967
  static MapaFase2 + #626, #3967
  static MapaFase2 + #627, #3967
  static MapaFase2 + #628, #3967
  static MapaFase2 + #629, #3967
  static MapaFase2 + #630, #3967
  static MapaFase2 + #631, #3967
  static MapaFase2 + #632, #3967
  static MapaFase2 + #633, #3967
  static MapaFase2 + #634, #3967
  static MapaFase2 + #635, #3967
  static MapaFase2 + #636, #3967
  static MapaFase2 + #637, #3967
  static MapaFase2 + #638, #3967
  static MapaFase2 + #639, #3967

  ;Linha 16
  static MapaFase2 + #640, #3967
  static MapaFase2 + #641, #3967
  static MapaFase2 + #642, #3967
  static MapaFase2 + #643, #3967
  static MapaFase2 + #644, #3967
  static MapaFase2 + #645, #3967
  static MapaFase2 + #646, #3967
  static MapaFase2 + #647, #3967
  static MapaFase2 + #648, #3967
  static MapaFase2 + #649, #3967
  static MapaFase2 + #650, #3967
  static MapaFase2 + #651, #3967
  static MapaFase2 + #652, #3967
  static MapaFase2 + #653, #3967
  static MapaFase2 + #654, #3967
  static MapaFase2 + #655, #3967
  static MapaFase2 + #656, #3967
  static MapaFase2 + #657, #3967
  static MapaFase2 + #658, #3967
  static MapaFase2 + #659, #3967
  static MapaFase2 + #660, #3967
  static MapaFase2 + #661, #3967
  static MapaFase2 + #662, #3967
  static MapaFase2 + #663, #3967
  static MapaFase2 + #664, #3967
  static MapaFase2 + #665, #3967
  static MapaFase2 + #666, #3967
  static MapaFase2 + #667, #3967
  static MapaFase2 + #668, #3967
  static MapaFase2 + #669, #3967
  static MapaFase2 + #670, #3967
  static MapaFase2 + #671, #3967
  static MapaFase2 + #672, #3967
  static MapaFase2 + #673, #3967
  static MapaFase2 + #674, #3967
  static MapaFase2 + #675, #3967
  static MapaFase2 + #676, #3967
  static MapaFase2 + #677, #3967
  static MapaFase2 + #678, #3967
  static MapaFase2 + #679, #3967

  ;Linha 17
  static MapaFase2 + #680, #3967
  static MapaFase2 + #681, #3967
  static MapaFase2 + #682, #3967
  static MapaFase2 + #683, #3967
  static MapaFase2 + #684, #3967
  static MapaFase2 + #685, #3967
  static MapaFase2 + #686, #3967
  static MapaFase2 + #687, #3967
  static MapaFase2 + #688, #3967
  static MapaFase2 + #689, #3967
  static MapaFase2 + #690, #3967
  static MapaFase2 + #691, #3967
  static MapaFase2 + #692, #3967
  static MapaFase2 + #693, #3967
  static MapaFase2 + #694, #3967
  static MapaFase2 + #695, #3967
  static MapaFase2 + #696, #3967
  static MapaFase2 + #697, #3967
  static MapaFase2 + #698, #3967
  static MapaFase2 + #699, #3967
  static MapaFase2 + #700, #3967
  static MapaFase2 + #701, #3967
  static MapaFase2 + #702, #3967
  static MapaFase2 + #703, #3967
  static MapaFase2 + #704, #3967
  static MapaFase2 + #705, #3967
  static MapaFase2 + #706, #3967
  static MapaFase2 + #707, #3967
  static MapaFase2 + #708, #3967
  static MapaFase2 + #709, #3967
  static MapaFase2 + #710, #3967
  static MapaFase2 + #711, #3967
  static MapaFase2 + #712, #3967
  static MapaFase2 + #713, #3967
  static MapaFase2 + #714, #3967
  static MapaFase2 + #715, #3967
  static MapaFase2 + #716, #3967
  static MapaFase2 + #717, #3967
  static MapaFase2 + #718, #3967
  static MapaFase2 + #719, #3967

  ;Linha 18
  static MapaFase2 + #720, #3967
  static MapaFase2 + #721, #3967
  static MapaFase2 + #722, #3967
  static MapaFase2 + #723, #3967
  static MapaFase2 + #724, #3967
  static MapaFase2 + #725, #3967
  static MapaFase2 + #726, #3967
  static MapaFase2 + #727, #3967
  static MapaFase2 + #728, #3967
  static MapaFase2 + #729, #3967
  static MapaFase2 + #730, #3967
  static MapaFase2 + #731, #3967
  static MapaFase2 + #732, #3967
  static MapaFase2 + #733, #3967
  static MapaFase2 + #734, #3967
  static MapaFase2 + #735, #3967
  static MapaFase2 + #736, #3967
  static MapaFase2 + #737, #3967
  static MapaFase2 + #738, #3967
  static MapaFase2 + #739, #3967
  static MapaFase2 + #740, #3967
  static MapaFase2 + #741, #3967
  static MapaFase2 + #742, #3967
  static MapaFase2 + #743, #3967
  static MapaFase2 + #744, #3967
  static MapaFase2 + #745, #3967
  static MapaFase2 + #746, #3967
  static MapaFase2 + #747, #3967
  static MapaFase2 + #748, #3967
  static MapaFase2 + #749, #3967
  static MapaFase2 + #750, #3967
  static MapaFase2 + #751, #3967
  static MapaFase2 + #752, #3967
  static MapaFase2 + #753, #3967
  static MapaFase2 + #754, #3967
  static MapaFase2 + #755, #3967
  static MapaFase2 + #756, #3967
  static MapaFase2 + #757, #3967
  static MapaFase2 + #758, #3967
  static MapaFase2 + #759, #3967

  ;Linha 19
  static MapaFase2 + #760, #3967
  static MapaFase2 + #761, #3967
  static MapaFase2 + #762, #3967
  static MapaFase2 + #763, #3967
  static MapaFase2 + #764, #3967
  static MapaFase2 + #765, #3967
  static MapaFase2 + #766, #3967
  static MapaFase2 + #767, #3967
  static MapaFase2 + #768, #3967
  static MapaFase2 + #769, #3967
  static MapaFase2 + #770, #3967
  static MapaFase2 + #771, #3967
  static MapaFase2 + #772, #3967
  static MapaFase2 + #773, #3967
  static MapaFase2 + #774, #3967
  static MapaFase2 + #775, #3904
  static MapaFase2 + #776, #3967
  static MapaFase2 + #777, #3967
  static MapaFase2 + #778, #3967
  static MapaFase2 + #779, #3967
  static MapaFase2 + #780, #3967
  static MapaFase2 + #781, #3967
  static MapaFase2 + #782, #3967
  static MapaFase2 + #783, #3967
  static MapaFase2 + #784, #3967
  static MapaFase2 + #785, #3967
  static MapaFase2 + #786, #3967
  static MapaFase2 + #787, #3967
  static MapaFase2 + #788, #3967
  static MapaFase2 + #789, #3967
  static MapaFase2 + #790, #3967
  static MapaFase2 + #791, #3967
  static MapaFase2 + #792, #3967
  static MapaFase2 + #793, #1067
  static MapaFase2 + #794, #3967
  static MapaFase2 + #795, #3967
  static MapaFase2 + #796, #3967
  static MapaFase2 + #797, #3967
  static MapaFase2 + #798, #3967
  static MapaFase2 + #799, #3967

  ;Linha 20
  static MapaFase2 + #800, #3967
  static MapaFase2 + #801, #3967
  static MapaFase2 + #802, #3967
  static MapaFase2 + #803, #3967
  static MapaFase2 + #804, #3967
  static MapaFase2 + #805, #3967
  static MapaFase2 + #806, #3967
  static MapaFase2 + #807, #3967
  static MapaFase2 + #808, #3967
  static MapaFase2 + #809, #3967
  static MapaFase2 + #810, #3967
  static MapaFase2 + #811, #3967
  static MapaFase2 + #812, #3967
  static MapaFase2 + #813, #3967
  static MapaFase2 + #814, #3967
  static MapaFase2 + #815, #1066
  static MapaFase2 + #816, #3967
  static MapaFase2 + #817, #3967
  static MapaFase2 + #818, #3967
  static MapaFase2 + #819, #3967
  static MapaFase2 + #820, #3967
  static MapaFase2 + #821, #3967
  static MapaFase2 + #822, #3967
  static MapaFase2 + #823, #3967
  static MapaFase2 + #824, #3967
  static MapaFase2 + #825, #3967
  static MapaFase2 + #826, #3967
  static MapaFase2 + #827, #3967
  static MapaFase2 + #828, #3967
  static MapaFase2 + #829, #3967
  static MapaFase2 + #830, #3967
  static MapaFase2 + #831, #3967
  static MapaFase2 + #832, #3967
  static MapaFase2 + #833, #3967
  static MapaFase2 + #834, #3967
  static MapaFase2 + #835, #3967
  static MapaFase2 + #836, #3967
  static MapaFase2 + #837, #3967
  static MapaFase2 + #838, #3967
  static MapaFase2 + #839, #3967

  ;Linha 21
  static MapaFase2 + #840, #3967
  static MapaFase2 + #841, #3967
  static MapaFase2 + #842, #3967
  static MapaFase2 + #843, #3967
  static MapaFase2 + #844, #3967
  static MapaFase2 + #845, #3967
  static MapaFase2 + #846, #3967
  static MapaFase2 + #847, #3967
  static MapaFase2 + #848, #3967
  static MapaFase2 + #849, #3967
  static MapaFase2 + #850, #3967
  static MapaFase2 + #851, #3967
  static MapaFase2 + #852, #3967
  static MapaFase2 + #853, #3967
  static MapaFase2 + #854, #3967
  static MapaFase2 + #855, #3967
  static MapaFase2 + #856, #3967
  static MapaFase2 + #857, #3967
  static MapaFase2 + #858, #3967
  static MapaFase2 + #859, #3967
  static MapaFase2 + #860, #3967
  static MapaFase2 + #861, #3967
  static MapaFase2 + #862, #3967
  static MapaFase2 + #863, #3967
  static MapaFase2 + #864, #3967
  static MapaFase2 + #865, #3967
  static MapaFase2 + #866, #3967
  static MapaFase2 + #867, #3967
  static MapaFase2 + #868, #3967
  static MapaFase2 + #869, #3967
  static MapaFase2 + #870, #3967
  static MapaFase2 + #871, #3967
  static MapaFase2 + #872, #3967
  static MapaFase2 + #873, #3967
  static MapaFase2 + #874, #3967
  static MapaFase2 + #875, #3967
  static MapaFase2 + #876, #3967
  static MapaFase2 + #877, #3967
  static MapaFase2 + #878, #3967
  static MapaFase2 + #879, #3967

  ;Linha 22
  static MapaFase2 + #880, #3967
  static MapaFase2 + #881, #3967
  static MapaFase2 + #882, #3967
  static MapaFase2 + #883, #3967
  static MapaFase2 + #884, #3967
  static MapaFase2 + #885, #3967
  static MapaFase2 + #886, #3967
  static MapaFase2 + #887, #3967
  static MapaFase2 + #888, #3967
  static MapaFase2 + #889, #3967
  static MapaFase2 + #890, #3967
  static MapaFase2 + #891, #3967
  static MapaFase2 + #892, #3967
  static MapaFase2 + #893, #3967
  static MapaFase2 + #894, #3967
  static MapaFase2 + #895, #3967
  static MapaFase2 + #896, #3967
  static MapaFase2 + #897, #3967
  static MapaFase2 + #898, #3967
  static MapaFase2 + #899, #3967
  static MapaFase2 + #900, #3967
  static MapaFase2 + #901, #3967
  static MapaFase2 + #902, #3967
  static MapaFase2 + #903, #3967
  static MapaFase2 + #904, #3967
  static MapaFase2 + #905, #3967
  static MapaFase2 + #906, #3967
  static MapaFase2 + #907, #3967
  static MapaFase2 + #908, #3967
  static MapaFase2 + #909, #3967
  static MapaFase2 + #910, #3967
  static MapaFase2 + #911, #3967
  static MapaFase2 + #912, #3967
  static MapaFase2 + #913, #3967
  static MapaFase2 + #914, #3967
  static MapaFase2 + #915, #3967
  static MapaFase2 + #916, #3967
  static MapaFase2 + #917, #3967
  static MapaFase2 + #918, #3967
  static MapaFase2 + #919, #3967

  ;Linha 23
  static MapaFase2 + #920, #3967
  static MapaFase2 + #921, #3967
  static MapaFase2 + #922, #3967
  static MapaFase2 + #923, #3967
  static MapaFase2 + #924, #3967
  static MapaFase2 + #925, #3967
  static MapaFase2 + #926, #3967
  static MapaFase2 + #927, #3967
  static MapaFase2 + #928, #3967
  static MapaFase2 + #929, #3967
  static MapaFase2 + #930, #3967
  static MapaFase2 + #931, #3967
  static MapaFase2 + #932, #3967
  static MapaFase2 + #933, #3967
  static MapaFase2 + #934, #3967
  static MapaFase2 + #935, #3967
  static MapaFase2 + #936, #3967
  static MapaFase2 + #937, #3967
  static MapaFase2 + #938, #3967
  static MapaFase2 + #939, #3967
  static MapaFase2 + #940, #3967
  static MapaFase2 + #941, #3967
  static MapaFase2 + #942, #3967
  static MapaFase2 + #943, #3967
  static MapaFase2 + #944, #3967
  static MapaFase2 + #945, #3967
  static MapaFase2 + #946, #3967
  static MapaFase2 + #947, #3967
  static MapaFase2 + #948, #3967
  static MapaFase2 + #949, #3967
  static MapaFase2 + #950, #3967
  static MapaFase2 + #951, #3967
  static MapaFase2 + #952, #3967
  static MapaFase2 + #953, #3967
  static MapaFase2 + #954, #3967
  static MapaFase2 + #955, #3967
  static MapaFase2 + #956, #3967
  static MapaFase2 + #957, #3967
  static MapaFase2 + #958, #3967
  static MapaFase2 + #959, #3967

  ;Linha 24
  static MapaFase2 + #960, #1067
  static MapaFase2 + #961, #3967
  static MapaFase2 + #962, #3967
  static MapaFase2 + #963, #3967
  static MapaFase2 + #964, #3967
  static MapaFase2 + #965, #3967
  static MapaFase2 + #966, #3967
  static MapaFase2 + #967, #3967
  static MapaFase2 + #968, #3967
  static MapaFase2 + #969, #3967
  static MapaFase2 + #970, #3967
  static MapaFase2 + #971, #3967
  static MapaFase2 + #972, #3967
  static MapaFase2 + #973, #3967
  static MapaFase2 + #974, #3967
  static MapaFase2 + #975, #3967
  static MapaFase2 + #976, #3967
  static MapaFase2 + #977, #3967
  static MapaFase2 + #978, #3967
  static MapaFase2 + #979, #3967
  static MapaFase2 + #980, #3967
  static MapaFase2 + #981, #3967
  static MapaFase2 + #982, #3967
  static MapaFase2 + #983, #3967
  static MapaFase2 + #984, #3967
  static MapaFase2 + #985, #3967
  static MapaFase2 + #986, #3967
  static MapaFase2 + #987, #3967
  static MapaFase2 + #988, #3967
  static MapaFase2 + #989, #3967
  static MapaFase2 + #990, #3967
  static MapaFase2 + #991, #3967
  static MapaFase2 + #992, #3967
  static MapaFase2 + #993, #3967
  static MapaFase2 + #994, #3967
  static MapaFase2 + #995, #3967
  static MapaFase2 + #996, #3967
  static MapaFase2 + #997, #3967
  static MapaFase2 + #998, #3967
  static MapaFase2 + #999, #3967

  ;Linha 25
  static MapaFase2 + #1000, #3967
  static MapaFase2 + #1001, #3967
  static MapaFase2 + #1002, #3967
  static MapaFase2 + #1003, #3967
  static MapaFase2 + #1004, #3967
  static MapaFase2 + #1005, #3967
  static MapaFase2 + #1006, #3967
  static MapaFase2 + #1007, #3967
  static MapaFase2 + #1008, #3967
  static MapaFase2 + #1009, #3967
  static MapaFase2 + #1010, #3967
  static MapaFase2 + #1011, #3967
  static MapaFase2 + #1012, #3967
  static MapaFase2 + #1013, #3967
  static MapaFase2 + #1014, #3967
  static MapaFase2 + #1015, #3967
  static MapaFase2 + #1016, #3967
  static MapaFase2 + #1017, #3967
  static MapaFase2 + #1018, #3967
  static MapaFase2 + #1019, #3967
  static MapaFase2 + #1020, #3967
  static MapaFase2 + #1021, #3967
  static MapaFase2 + #1022, #3967
  static MapaFase2 + #1023, #3967
  static MapaFase2 + #1024, #3967
  static MapaFase2 + #1025, #3967
  static MapaFase2 + #1026, #3967
  static MapaFase2 + #1027, #3967
  static MapaFase2 + #1028, #3967
  static MapaFase2 + #1029, #3967
  static MapaFase2 + #1030, #3967
  static MapaFase2 + #1031, #3967
  static MapaFase2 + #1032, #3967
  static MapaFase2 + #1033, #3967
  static MapaFase2 + #1034, #3967
  static MapaFase2 + #1035, #3967
  static MapaFase2 + #1036, #3967
  static MapaFase2 + #1037, #3967
  static MapaFase2 + #1038, #3967
  static MapaFase2 + #1039, #3967

  ;Linha 26
  static MapaFase2 + #1040, #3967
  static MapaFase2 + #1041, #3967
  static MapaFase2 + #1042, #3967
  static MapaFase2 + #1043, #3967
  static MapaFase2 + #1044, #3967
  static MapaFase2 + #1045, #3967
  static MapaFase2 + #1046, #3967
  static MapaFase2 + #1047, #3967
  static MapaFase2 + #1048, #3967
  static MapaFase2 + #1049, #3967
  static MapaFase2 + #1050, #3967
  static MapaFase2 + #1051, #3967
  static MapaFase2 + #1052, #3967
  static MapaFase2 + #1053, #3967
  static MapaFase2 + #1054, #3967
  static MapaFase2 + #1055, #3967
  static MapaFase2 + #1056, #3967
  static MapaFase2 + #1057, #3967
  static MapaFase2 + #1058, #3967
  static MapaFase2 + #1059, #3967
  static MapaFase2 + #1060, #3967
  static MapaFase2 + #1061, #3967
  static MapaFase2 + #1062, #3967
  static MapaFase2 + #1063, #3967
  static MapaFase2 + #1064, #3967
  static MapaFase2 + #1065, #3967
  static MapaFase2 + #1066, #3967
  static MapaFase2 + #1067, #3967
  static MapaFase2 + #1068, #1088
  static MapaFase2 + #1069, #3967
  static MapaFase2 + #1070, #3967
  static MapaFase2 + #1071, #3967
  static MapaFase2 + #1072, #3967
  static MapaFase2 + #1073, #3967
  static MapaFase2 + #1074, #3967
  static MapaFase2 + #1075, #3967
  static MapaFase2 + #1076, #3967
  static MapaFase2 + #1077, #3967
  static MapaFase2 + #1078, #3967
  static MapaFase2 + #1079, #3967

  ;Linha 27
  static MapaFase2 + #1080, #3967
  static MapaFase2 + #1081, #3967
  static MapaFase2 + #1082, #3967
  static MapaFase2 + #1083, #3967
  static MapaFase2 + #1084, #3967
  static MapaFase2 + #1085, #3967
  static MapaFase2 + #1086, #3967
  static MapaFase2 + #1087, #3967
  static MapaFase2 + #1088, #3967
  static MapaFase2 + #1089, #3967
  static MapaFase2 + #1090, #3967
  static MapaFase2 + #1091, #3967
  static MapaFase2 + #1092, #3967
  static MapaFase2 + #1093, #3967
  static MapaFase2 + #1094, #3967
  static MapaFase2 + #1095, #3967
  static MapaFase2 + #1096, #3967
  static MapaFase2 + #1097, #3967
  static MapaFase2 + #1098, #3967
  static MapaFase2 + #1099, #3967
  static MapaFase2 + #1100, #3967
  static MapaFase2 + #1101, #3967
  static MapaFase2 + #1102, #3967
  static MapaFase2 + #1103, #3967
  static MapaFase2 + #1104, #3967
  static MapaFase2 + #1105, #3967
  static MapaFase2 + #1106, #3967
  static MapaFase2 + #1107, #3967
  static MapaFase2 + #1108, #3967
  static MapaFase2 + #1109, #3967
  static MapaFase2 + #1110, #3967
  static MapaFase2 + #1111, #3967
  static MapaFase2 + #1112, #3967
  static MapaFase2 + #1113, #3967
  static MapaFase2 + #1114, #3967
  static MapaFase2 + #1115, #3967
  static MapaFase2 + #1116, #3967
  static MapaFase2 + #1117, #3967
  static MapaFase2 + #1118, #3967
  static MapaFase2 + #1119, #3967

  ;Linha 28
  static MapaFase2 + #1120, #3967
  static MapaFase2 + #1121, #3967
  static MapaFase2 + #1122, #3967
  static MapaFase2 + #1123, #3967
  static MapaFase2 + #1124, #3967
  static MapaFase2 + #1125, #3967
  static MapaFase2 + #1126, #3967
  static MapaFase2 + #1127, #3967
  static MapaFase2 + #1128, #3967
  static MapaFase2 + #1129, #3967
  static MapaFase2 + #1130, #3967
  static MapaFase2 + #1131, #3967
  static MapaFase2 + #1132, #3967
  static MapaFase2 + #1133, #3967
  static MapaFase2 + #1134, #3967
  static MapaFase2 + #1135, #3967
  static MapaFase2 + #1136, #3967
  static MapaFase2 + #1137, #3967
  static MapaFase2 + #1138, #3967
  static MapaFase2 + #1139, #3967
  static MapaFase2 + #1140, #3967
  static MapaFase2 + #1141, #3967
  static MapaFase2 + #1142, #3967
  static MapaFase2 + #1143, #3967
  static MapaFase2 + #1144, #3967
  static MapaFase2 + #1145, #3967
  static MapaFase2 + #1146, #3967
  static MapaFase2 + #1147, #3967
  static MapaFase2 + #1148, #3967
  static MapaFase2 + #1149, #3967
  static MapaFase2 + #1150, #3967
  static MapaFase2 + #1151, #3967
  static MapaFase2 + #1152, #3967
  static MapaFase2 + #1153, #3967
  static MapaFase2 + #1154, #3967
  static MapaFase2 + #1155, #3967
  static MapaFase2 + #1156, #3967
  static MapaFase2 + #1157, #3967
  static MapaFase2 + #1158, #3967
  static MapaFase2 + #1159, #3967

  ;Linha 29
  static MapaFase2 + #1160, #3967
  static MapaFase2 + #1161, #3967
  static MapaFase2 + #1162, #3967
  static MapaFase2 + #1163, #3967
  static MapaFase2 + #1164, #3967
  static MapaFase2 + #1165, #3967
  static MapaFase2 + #1166, #3967
  static MapaFase2 + #1167, #3967
  static MapaFase2 + #1168, #3967
  static MapaFase2 + #1169, #3967
  static MapaFase2 + #1170, #3967
  static MapaFase2 + #1171, #3967
  static MapaFase2 + #1172, #3967
  static MapaFase2 + #1173, #3967
  static MapaFase2 + #1174, #3967
  static MapaFase2 + #1175, #3967
  static MapaFase2 + #1176, #3967
  static MapaFase2 + #1177, #3967
  static MapaFase2 + #1178, #3967
  static MapaFase2 + #1179, #3967
  static MapaFase2 + #1180, #3967
  static MapaFase2 + #1181, #3967
  static MapaFase2 + #1182, #3967
  static MapaFase2 + #1183, #3967
  static MapaFase2 + #1184, #3967
  static MapaFase2 + #1185, #3967
  static MapaFase2 + #1186, #3967
  static MapaFase2 + #1187, #3967
  static MapaFase2 + #1188, #3967
  static MapaFase2 + #1189, #3967
  static MapaFase2 + #1190, #3967
  static MapaFase2 + #1191, #3967
  static MapaFase2 + #1192, #3967
  static MapaFase2 + #1193, #3967
  static MapaFase2 + #1194, #3967
  static MapaFase2 + #1195, #3967
  static MapaFase2 + #1196, #3967
  static MapaFase2 + #1197, #3967
  static MapaFase2 + #1198, #3967
  static MapaFase2 + #1199, #3967

MapaFase3 : var #1200
  ;Linha 0
  static MapaFase3 + #0, #3967
  static MapaFase3 + #1, #3967
  static MapaFase3 + #2, #3967
  static MapaFase3 + #3, #3967
  static MapaFase3 + #4, #3967
  static MapaFase3 + #5, #3967
  static MapaFase3 + #6, #3967
  static MapaFase3 + #7, #3967
  static MapaFase3 + #8, #3967
  static MapaFase3 + #9, #3967
  static MapaFase3 + #10, #3967
  static MapaFase3 + #11, #3967
  static MapaFase3 + #12, #3967
  static MapaFase3 + #13, #3967
  static MapaFase3 + #14, #3967
  static MapaFase3 + #15, #3967
  static MapaFase3 + #16, #3967
  static MapaFase3 + #17, #3967
  static MapaFase3 + #18, #3967
  static MapaFase3 + #19, #3967
  static MapaFase3 + #20, #3967
  static MapaFase3 + #21, #3967
  static MapaFase3 + #22, #3967
  static MapaFase3 + #23, #3967
  static MapaFase3 + #24, #3967
  static MapaFase3 + #25, #3967
  static MapaFase3 + #26, #3967
  static MapaFase3 + #27, #3967
  static MapaFase3 + #28, #0
  static MapaFase3 + #29, #3967
  static MapaFase3 + #30, #3967
  static MapaFase3 + #31, #3967
  static MapaFase3 + #32, #3967
  static MapaFase3 + #33, #3967
  static MapaFase3 + #34, #3967
  static MapaFase3 + #35, #3967
  static MapaFase3 + #36, #3967
  static MapaFase3 + #37, #3967
  static MapaFase3 + #38, #3967
  static MapaFase3 + #39, #3967

  ;Linha 1
  static MapaFase3 + #40, #3967
  static MapaFase3 + #41, #3967
  static MapaFase3 + #42, #3967
  static MapaFase3 + #43, #3967
  static MapaFase3 + #44, #3967
  static MapaFase3 + #45, #3967
  static MapaFase3 + #46, #3967
  static MapaFase3 + #47, #3967
  static MapaFase3 + #48, #3967
  static MapaFase3 + #49, #3967
  static MapaFase3 + #50, #3967
  static MapaFase3 + #51, #3967
  static MapaFase3 + #52, #3967
  static MapaFase3 + #53, #3967
  static MapaFase3 + #54, #3967
  static MapaFase3 + #55, #3967
  static MapaFase3 + #56, #3967
  static MapaFase3 + #57, #3967
  static MapaFase3 + #58, #3967
  static MapaFase3 + #59, #3967
  static MapaFase3 + #60, #3967
  static MapaFase3 + #61, #3967
  static MapaFase3 + #62, #3967
  static MapaFase3 + #63, #3967
  static MapaFase3 + #64, #3967
  static MapaFase3 + #65, #3967
  static MapaFase3 + #66, #3967
  static MapaFase3 + #67, #3967
  static MapaFase3 + #68, #0
  static MapaFase3 + #69, #3967
  static MapaFase3 + #70, #3967
  static MapaFase3 + #71, #3967
  static MapaFase3 + #72, #3967
  static MapaFase3 + #73, #3967
  static MapaFase3 + #74, #3878
  static MapaFase3 + #75, #3878
  static MapaFase3 + #76, #3878
  static MapaFase3 + #77, #3967
  static MapaFase3 + #78, #3967
  static MapaFase3 + #79, #3967

  ;Linha 2
  static MapaFase3 + #80, #3967
  static MapaFase3 + #81, #3967
  static MapaFase3 + #82, #3967
  static MapaFase3 + #83, #3967
  static MapaFase3 + #84, #3967
  static MapaFase3 + #85, #3967
  static MapaFase3 + #86, #3967
  static MapaFase3 + #87, #3967
  static MapaFase3 + #88, #3967
  static MapaFase3 + #89, #3967
  static MapaFase3 + #90, #3967
  static MapaFase3 + #91, #3967
  static MapaFase3 + #92, #3967
  static MapaFase3 + #93, #3967
  static MapaFase3 + #94, #3967
  static MapaFase3 + #95, #3967
  static MapaFase3 + #96, #3967
  static MapaFase3 + #97, #3967
  static MapaFase3 + #98, #3967
  static MapaFase3 + #99, #3967
  static MapaFase3 + #100, #3967
  static MapaFase3 + #101, #3967
  static MapaFase3 + #102, #3967
  static MapaFase3 + #103, #3967
  static MapaFase3 + #104, #3967
  static MapaFase3 + #105, #3967
  static MapaFase3 + #106, #3967
  static MapaFase3 + #107, #3967
  static MapaFase3 + #108, #3967
  static MapaFase3 + #109, #3876
  static MapaFase3 + #110, #3876
  static MapaFase3 + #111, #3967
  static MapaFase3 + #112, #3967
  static MapaFase3 + #113, #3967
  static MapaFase3 + #114, #3878
  static MapaFase3 + #115, #3878
  static MapaFase3 + #116, #3878
  static MapaFase3 + #117, #3967
  static MapaFase3 + #118, #1066
  static MapaFase3 + #119, #3967

  ;Linha 3
  static MapaFase3 + #120, #3967
  static MapaFase3 + #121, #3967
  static MapaFase3 + #122, #3967
  static MapaFase3 + #123, #3967
  static MapaFase3 + #124, #3967
  static MapaFase3 + #125, #3967
  static MapaFase3 + #126, #3967
  static MapaFase3 + #127, #3967
  static MapaFase3 + #128, #3967
  static MapaFase3 + #129, #3967
  static MapaFase3 + #130, #3967
  static MapaFase3 + #131, #3967
  static MapaFase3 + #132, #3967
  static MapaFase3 + #133, #3967
  static MapaFase3 + #134, #3967
  static MapaFase3 + #135, #3967
  static MapaFase3 + #136, #3967
  static MapaFase3 + #137, #3967
  static MapaFase3 + #138, #3967
  static MapaFase3 + #139, #3967
  static MapaFase3 + #140, #3967
  static MapaFase3 + #141, #3967
  static MapaFase3 + #142, #3967
  static MapaFase3 + #143, #3967
  static MapaFase3 + #144, #3967
  static MapaFase3 + #145, #3967
  static MapaFase3 + #146, #3876
  static MapaFase3 + #147, #2049
  static MapaFase3 + #148, #1828
  static MapaFase3 + #149, #1828
  static MapaFase3 + #150, #2084
  static MapaFase3 + #151, #1828
  static MapaFase3 + #152, #1828
  static MapaFase3 + #153, #2085
  static MapaFase3 + #154, #3876
  static MapaFase3 + #155, #3878
  static MapaFase3 + #156, #3878
  static MapaFase3 + #157, #3967
  static MapaFase3 + #158, #3967
  static MapaFase3 + #159, #3967

  ;Linha 4
  static MapaFase3 + #160, #3967
  static MapaFase3 + #161, #3967
  static MapaFase3 + #162, #3967
  static MapaFase3 + #163, #3967
  static MapaFase3 + #164, #3967
  static MapaFase3 + #165, #3967
  static MapaFase3 + #166, #3967
  static MapaFase3 + #167, #3967
  static MapaFase3 + #168, #3967
  static MapaFase3 + #169, #3967
  static MapaFase3 + #170, #3967
  static MapaFase3 + #171, #3967
  static MapaFase3 + #172, #3967
  static MapaFase3 + #173, #3967
  static MapaFase3 + #174, #3967
  static MapaFase3 + #175, #3967
  static MapaFase3 + #176, #3967
  static MapaFase3 + #177, #3967
  static MapaFase3 + #178, #3967
  static MapaFase3 + #179, #3967
  static MapaFase3 + #180, #3967
  static MapaFase3 + #181, #3967
  static MapaFase3 + #182, #3967
  static MapaFase3 + #183, #3967
  static MapaFase3 + #184, #3967
  static MapaFase3 + #185, #3876
  static MapaFase3 + #186, #1793
  static MapaFase3 + #187, #2084
  static MapaFase3 + #188, #1828
  static MapaFase3 + #189, #1828
  static MapaFase3 + #190, #2084
  static MapaFase3 + #191, #1828
  static MapaFase3 + #192, #1828
  static MapaFase3 + #193, #2084
  static MapaFase3 + #194, #1829
  static MapaFase3 + #195, #3876
  static MapaFase3 + #196, #3967
  static MapaFase3 + #197, #3967
  static MapaFase3 + #198, #3967
  static MapaFase3 + #199, #3967

  ;Linha 5
  static MapaFase3 + #200, #3967
  static MapaFase3 + #201, #3967
  static MapaFase3 + #202, #3967
  static MapaFase3 + #203, #3967
  static MapaFase3 + #204, #1088
  static MapaFase3 + #205, #3967
  static MapaFase3 + #206, #3967
  static MapaFase3 + #207, #3967
  static MapaFase3 + #208, #3967
  static MapaFase3 + #209, #3967
  static MapaFase3 + #210, #3967
  static MapaFase3 + #211, #3967
  static MapaFase3 + #212, #3967
  static MapaFase3 + #213, #3967
  static MapaFase3 + #214, #3967
  static MapaFase3 + #215, #3967
  static MapaFase3 + #216, #3967
  static MapaFase3 + #217, #3967
  static MapaFase3 + #218, #3967
  static MapaFase3 + #219, #3967
  static MapaFase3 + #220, #3967
  static MapaFase3 + #221, #3967
  static MapaFase3 + #222, #3967
  static MapaFase3 + #223, #3967
  static MapaFase3 + #224, #3876
  static MapaFase3 + #225, #2049
  static MapaFase3 + #226, #1828
  static MapaFase3 + #227, #2071
  static MapaFase3 + #228, #2139
  static MapaFase3 + #229, #2068
  static MapaFase3 + #230, #2084
  static MapaFase3 + #231, #1828
  static MapaFase3 + #232, #1828
  static MapaFase3 + #233, #2084
  static MapaFase3 + #234, #1828
  static MapaFase3 + #235, #2085
  static MapaFase3 + #236, #3876
  static MapaFase3 + #237, #3876
  static MapaFase3 + #238, #3967
  static MapaFase3 + #239, #3967

  ;Linha 6
  static MapaFase3 + #240, #3967
  static MapaFase3 + #241, #3967
  static MapaFase3 + #242, #3967
  static MapaFase3 + #243, #3967
  static MapaFase3 + #244, #3967
  static MapaFase3 + #245, #3967
  static MapaFase3 + #246, #3967
  static MapaFase3 + #247, #3967
  static MapaFase3 + #248, #3967
  static MapaFase3 + #249, #3967
  static MapaFase3 + #250, #3967
  static MapaFase3 + #251, #3967
  static MapaFase3 + #252, #3967
  static MapaFase3 + #253, #3967
  static MapaFase3 + #254, #3967
  static MapaFase3 + #255, #3967
  static MapaFase3 + #256, #3967
  static MapaFase3 + #257, #3967
  static MapaFase3 + #258, #3967
  static MapaFase3 + #259, #3967
  static MapaFase3 + #260, #3967
  static MapaFase3 + #261, #3967
  static MapaFase3 + #262, #3967
  static MapaFase3 + #263, #3876
  static MapaFase3 + #264, #1793
  static MapaFase3 + #265, #2084
  static MapaFase3 + #266, #1828
  static MapaFase3 + #267, #2172
  static MapaFase3 + #268, #2140
  static MapaFase3 + #269, #2173
  static MapaFase3 + #270, #2084
  static MapaFase3 + #271, #1828
  static MapaFase3 + #272, #1828
  static MapaFase3 + #273, #2084
  static MapaFase3 + #274, #1828
  static MapaFase3 + #275, #2084
  static MapaFase3 + #276, #1829
  static MapaFase3 + #277, #3876
  static MapaFase3 + #278, #3864
  static MapaFase3 + #279, #3967

  ;Linha 7
  static MapaFase3 + #280, #3967
  static MapaFase3 + #281, #3967
  static MapaFase3 + #282, #3967
  static MapaFase3 + #283, #3967
  static MapaFase3 + #284, #3967
  static MapaFase3 + #285, #3967
  static MapaFase3 + #286, #3967
  static MapaFase3 + #287, #3967
  static MapaFase3 + #288, #3967
  static MapaFase3 + #289, #3967
  static MapaFase3 + #290, #3967
  static MapaFase3 + #291, #3967
  static MapaFase3 + #292, #3967
  static MapaFase3 + #293, #3967
  static MapaFase3 + #294, #3967
  static MapaFase3 + #295, #3967
  static MapaFase3 + #296, #3967
  static MapaFase3 + #297, #3967
  static MapaFase3 + #298, #3967
  static MapaFase3 + #299, #3967
  static MapaFase3 + #300, #3967
  static MapaFase3 + #301, #3967
  static MapaFase3 + #302, #3876
  static MapaFase3 + #303, #1793
  static MapaFase3 + #304, #1828
  static MapaFase3 + #305, #2084
  static MapaFase3 + #306, #1828
  static MapaFase3 + #307, #2070
  static MapaFase3 + #308, #2171
  static MapaFase3 + #309, #2069
  static MapaFase3 + #310, #2084
  static MapaFase3 + #311, #1828
  static MapaFase3 + #312, #1828
  static MapaFase3 + #313, #2084
  static MapaFase3 + #314, #1828
  static MapaFase3 + #315, #2084
  static MapaFase3 + #316, #1828
  static MapaFase3 + #317, #1829
  static MapaFase3 + #318, #3967
  static MapaFase3 + #319, #3967

  ;Linha 8
  static MapaFase3 + #320, #3967
  static MapaFase3 + #321, #3967
  static MapaFase3 + #322, #3967
  static MapaFase3 + #323, #3967
  static MapaFase3 + #324, #3967
  static MapaFase3 + #325, #3967
  static MapaFase3 + #326, #3967
  static MapaFase3 + #327, #3967
  static MapaFase3 + #328, #3967
  static MapaFase3 + #329, #3967
  static MapaFase3 + #330, #3967
  static MapaFase3 + #331, #3967
  static MapaFase3 + #332, #3967
  static MapaFase3 + #333, #3967
  static MapaFase3 + #334, #3967
  static MapaFase3 + #335, #3967
  static MapaFase3 + #336, #3967
  static MapaFase3 + #337, #3967
  static MapaFase3 + #338, #3967
  static MapaFase3 + #339, #3967
  static MapaFase3 + #340, #3967
  static MapaFase3 + #341, #3967
  static MapaFase3 + #342, #3967
  static MapaFase3 + #343, #1828
  static MapaFase3 + #344, #1828
  static MapaFase3 + #345, #2084
  static MapaFase3 + #346, #1828
  static MapaFase3 + #347, #2084
  static MapaFase3 + #348, #1828
  static MapaFase3 + #349, #1828
  static MapaFase3 + #350, #2084
  static MapaFase3 + #351, #1828
  static MapaFase3 + #352, #1828
  static MapaFase3 + #353, #2084
  static MapaFase3 + #354, #1828
  static MapaFase3 + #355, #2084
  static MapaFase3 + #356, #1828
  static MapaFase3 + #357, #1828
  static MapaFase3 + #358, #3967
  static MapaFase3 + #359, #3967

  ;Linha 9
  static MapaFase3 + #360, #3967
  static MapaFase3 + #361, #3967
  static MapaFase3 + #362, #3967
  static MapaFase3 + #363, #3967
  static MapaFase3 + #364, #3967
  static MapaFase3 + #365, #3967
  static MapaFase3 + #366, #3967
  static MapaFase3 + #367, #3967
  static MapaFase3 + #368, #3967
  static MapaFase3 + #369, #3967
  static MapaFase3 + #370, #3967
  static MapaFase3 + #371, #3967
  static MapaFase3 + #372, #1067
  static MapaFase3 + #373, #3967
  static MapaFase3 + #374, #3967
  static MapaFase3 + #375, #3967
  static MapaFase3 + #376, #3967
  static MapaFase3 + #377, #3967
  static MapaFase3 + #378, #3967
  static MapaFase3 + #379, #3967
  static MapaFase3 + #380, #3967
  static MapaFase3 + #381, #3967
  static MapaFase3 + #382, #3967
  static MapaFase3 + #383, #1828
  static MapaFase3 + #384, #1828
  static MapaFase3 + #385, #2084
  static MapaFase3 + #386, #1828
  static MapaFase3 + #387, #2084
  static MapaFase3 + #388, #1828
  static MapaFase3 + #389, #1828
  static MapaFase3 + #390, #2084
  static MapaFase3 + #391, #1828
  static MapaFase3 + #392, #1828
  static MapaFase3 + #393, #2084
  static MapaFase3 + #394, #1828
  static MapaFase3 + #395, #2084
  static MapaFase3 + #396, #1828
  static MapaFase3 + #397, #1828
  static MapaFase3 + #398, #3967
  static MapaFase3 + #399, #3967

  ;Linha 10
  static MapaFase3 + #400, #3967
  static MapaFase3 + #401, #3967
  static MapaFase3 + #402, #3967
  static MapaFase3 + #403, #3967
  static MapaFase3 + #404, #3967
  static MapaFase3 + #405, #3967
  static MapaFase3 + #406, #3967
  static MapaFase3 + #407, #3967
  static MapaFase3 + #408, #3967
  static MapaFase3 + #409, #3967
  static MapaFase3 + #410, #3967
  static MapaFase3 + #411, #3967
  static MapaFase3 + #412, #3967
  static MapaFase3 + #413, #3967
  static MapaFase3 + #414, #3967
  static MapaFase3 + #415, #3967
  static MapaFase3 + #416, #3967
  static MapaFase3 + #417, #3967
  static MapaFase3 + #418, #3967
  static MapaFase3 + #419, #3967
  static MapaFase3 + #420, #3967
  static MapaFase3 + #421, #3967
  static MapaFase3 + #422, #3967
  static MapaFase3 + #423, #2072
  static MapaFase3 + #424, #2072
  static MapaFase3 + #425, #2072
  static MapaFase3 + #426, #2072
  static MapaFase3 + #427, #2072
  static MapaFase3 + #428, #2072
  static MapaFase3 + #429, #2072
  static MapaFase3 + #430, #2072
  static MapaFase3 + #431, #2072
  static MapaFase3 + #432, #2072
  static MapaFase3 + #433, #2072
  static MapaFase3 + #434, #2072
  static MapaFase3 + #435, #2072
  static MapaFase3 + #436, #2072
  static MapaFase3 + #437, #2072
  static MapaFase3 + #438, #3967
  static MapaFase3 + #439, #3967

  ;Linha 11
  static MapaFase3 + #440, #3967
  static MapaFase3 + #441, #3967
  static MapaFase3 + #442, #3967
  static MapaFase3 + #443, #3967
  static MapaFase3 + #444, #3967
  static MapaFase3 + #445, #3967
  static MapaFase3 + #446, #3967
  static MapaFase3 + #447, #3967
  static MapaFase3 + #448, #3967
  static MapaFase3 + #449, #3967
  static MapaFase3 + #450, #3967
  static MapaFase3 + #451, #3967
  static MapaFase3 + #452, #3967
  static MapaFase3 + #453, #3967
  static MapaFase3 + #454, #3967
  static MapaFase3 + #455, #3967
  static MapaFase3 + #456, #3967
  static MapaFase3 + #457, #3967
  static MapaFase3 + #458, #3967
  static MapaFase3 + #459, #3967
  static MapaFase3 + #460, #3967
  static MapaFase3 + #461, #3967
  static MapaFase3 + #462, #3967
  static MapaFase3 + #463, #1828
  static MapaFase3 + #464, #2084
  static MapaFase3 + #465, #1828
  static MapaFase3 + #466, #1828
  static MapaFase3 + #467, #2084
  static MapaFase3 + #468, #1828
  static MapaFase3 + #469, #2084
  static MapaFase3 + #470, #1828
  static MapaFase3 + #471, #1828
  static MapaFase3 + #472, #2084
  static MapaFase3 + #473, #1828
  static MapaFase3 + #474, #2084
  static MapaFase3 + #475, #1828
  static MapaFase3 + #476, #1828
  static MapaFase3 + #477, #2084
  static MapaFase3 + #478, #3967
  static MapaFase3 + #479, #3967

  ;Linha 12
  static MapaFase3 + #480, #3967
  static MapaFase3 + #481, #3967
  static MapaFase3 + #482, #3967
  static MapaFase3 + #483, #3967
  static MapaFase3 + #484, #3967
  static MapaFase3 + #485, #3967
  static MapaFase3 + #486, #3967
  static MapaFase3 + #487, #3967
  static MapaFase3 + #488, #3967
  static MapaFase3 + #489, #3967
  static MapaFase3 + #490, #3967
  static MapaFase3 + #491, #3967
  static MapaFase3 + #492, #3967
  static MapaFase3 + #493, #3967
  static MapaFase3 + #494, #3967
  static MapaFase3 + #495, #3967
  static MapaFase3 + #496, #3967
  static MapaFase3 + #497, #3967
  static MapaFase3 + #498, #3967
  static MapaFase3 + #499, #3967
  static MapaFase3 + #500, #3967
  static MapaFase3 + #501, #3967
  static MapaFase3 + #502, #3967
  static MapaFase3 + #503, #1828
  static MapaFase3 + #504, #2084
  static MapaFase3 + #505, #1828
  static MapaFase3 + #506, #1828
  static MapaFase3 + #507, #2084
  static MapaFase3 + #508, #1828
  static MapaFase3 + #509, #2084
  static MapaFase3 + #510, #1828
  static MapaFase3 + #511, #1828
  static MapaFase3 + #512, #2084
  static MapaFase3 + #513, #1828
  static MapaFase3 + #514, #2084
  static MapaFase3 + #515, #1828
  static MapaFase3 + #516, #1828
  static MapaFase3 + #517, #2084
  static MapaFase3 + #518, #3967
  static MapaFase3 + #519, #3967

  ;Linha 13
  static MapaFase3 + #520, #3967
  static MapaFase3 + #521, #3967
  static MapaFase3 + #522, #3967
  static MapaFase3 + #523, #3967
  static MapaFase3 + #524, #3967
  static MapaFase3 + #525, #3967
  static MapaFase3 + #526, #3967
  static MapaFase3 + #527, #3967
  static MapaFase3 + #528, #3967
  static MapaFase3 + #529, #3967
  static MapaFase3 + #530, #3967
  static MapaFase3 + #531, #3967
  static MapaFase3 + #532, #3967
  static MapaFase3 + #533, #3967
  static MapaFase3 + #534, #3967
  static MapaFase3 + #535, #3967
  static MapaFase3 + #536, #3967
  static MapaFase3 + #537, #3967
  static MapaFase3 + #538, #3967
  static MapaFase3 + #539, #3967
  static MapaFase3 + #540, #3967
  static MapaFase3 + #541, #3967
  static MapaFase3 + #542, #3967
  static MapaFase3 + #543, #1823
  static MapaFase3 + #544, #2084
  static MapaFase3 + #545, #1828
  static MapaFase3 + #546, #1828
  static MapaFase3 + #547, #2084
  static MapaFase3 + #548, #1828
  static MapaFase3 + #549, #2084
  static MapaFase3 + #550, #1828
  static MapaFase3 + #551, #1828
  static MapaFase3 + #552, #2084
  static MapaFase3 + #553, #1828
  static MapaFase3 + #554, #2084
  static MapaFase3 + #555, #1828
  static MapaFase3 + #556, #1828
  static MapaFase3 + #557, #2107
  static MapaFase3 + #558, #3967
  static MapaFase3 + #559, #3967

  ;Linha 14
  static MapaFase3 + #560, #3967
  static MapaFase3 + #561, #3967
  static MapaFase3 + #562, #3967
  static MapaFase3 + #563, #3967
  static MapaFase3 + #564, #3967
  static MapaFase3 + #565, #3967
  static MapaFase3 + #566, #3967
  static MapaFase3 + #567, #3967
  static MapaFase3 + #568, #3967
  static MapaFase3 + #569, #3967
  static MapaFase3 + #570, #3967
  static MapaFase3 + #571, #3967
  static MapaFase3 + #572, #3967
  static MapaFase3 + #573, #3967
  static MapaFase3 + #574, #3967
  static MapaFase3 + #575, #3967
  static MapaFase3 + #576, #3967
  static MapaFase3 + #577, #3967
  static MapaFase3 + #578, #3967
  static MapaFase3 + #579, #3967
  static MapaFase3 + #580, #3967
  static MapaFase3 + #581, #3967
  static MapaFase3 + #582, #3967
  static MapaFase3 + #583, #3876
  static MapaFase3 + #584, #2079
  static MapaFase3 + #585, #1828
  static MapaFase3 + #586, #1828
  static MapaFase3 + #587, #2084
  static MapaFase3 + #588, #1828
  static MapaFase3 + #589, #2084
  static MapaFase3 + #590, #1828
  static MapaFase3 + #591, #1828
  static MapaFase3 + #592, #2084
  static MapaFase3 + #593, #1828
  static MapaFase3 + #594, #2084
  static MapaFase3 + #595, #1828
  static MapaFase3 + #596, #1851
  static MapaFase3 + #597, #3876
  static MapaFase3 + #598, #3967
  static MapaFase3 + #599, #3967

  ;Linha 15
  static MapaFase3 + #600, #3967
  static MapaFase3 + #601, #3967
  static MapaFase3 + #602, #3967
  static MapaFase3 + #603, #3967
  static MapaFase3 + #604, #3967
  static MapaFase3 + #605, #3967
  static MapaFase3 + #606, #3967
  static MapaFase3 + #607, #3967
  static MapaFase3 + #608, #3967
  static MapaFase3 + #609, #3967
  static MapaFase3 + #610, #3967
  static MapaFase3 + #611, #3967
  static MapaFase3 + #612, #3967
  static MapaFase3 + #613, #3967
  static MapaFase3 + #614, #3967
  static MapaFase3 + #615, #3967
  static MapaFase3 + #616, #3967
  static MapaFase3 + #617, #3967
  static MapaFase3 + #618, #3967
  static MapaFase3 + #619, #3967
  static MapaFase3 + #620, #3967
  static MapaFase3 + #621, #3967
  static MapaFase3 + #622, #3967
  static MapaFase3 + #623, #3967
  static MapaFase3 + #624, #3876
  static MapaFase3 + #625, #1823
  static MapaFase3 + #626, #1828
  static MapaFase3 + #627, #2084
  static MapaFase3 + #628, #1828
  static MapaFase3 + #629, #2084
  static MapaFase3 + #630, #1828
  static MapaFase3 + #631, #1828
  static MapaFase3 + #632, #2084
  static MapaFase3 + #633, #1828
  static MapaFase3 + #634, #2084
  static MapaFase3 + #635, #1851
  static MapaFase3 + #636, #3876
  static MapaFase3 + #637, #3967
  static MapaFase3 + #638, #3967
  static MapaFase3 + #639, #3967

  ;Linha 16
  static MapaFase3 + #640, #3967
  static MapaFase3 + #641, #3967
  static MapaFase3 + #642, #3967
  static MapaFase3 + #643, #3967
  static MapaFase3 + #644, #3967
  static MapaFase3 + #645, #3967
  static MapaFase3 + #646, #3967
  static MapaFase3 + #647, #3967
  static MapaFase3 + #648, #3967
  static MapaFase3 + #649, #3967
  static MapaFase3 + #650, #3967
  static MapaFase3 + #651, #3967
  static MapaFase3 + #652, #3967
  static MapaFase3 + #653, #3967
  static MapaFase3 + #654, #3967
  static MapaFase3 + #655, #3967
  static MapaFase3 + #656, #3967
  static MapaFase3 + #657, #3967
  static MapaFase3 + #658, #3967
  static MapaFase3 + #659, #3967
  static MapaFase3 + #660, #3967
  static MapaFase3 + #661, #3967
  static MapaFase3 + #662, #3967
  static MapaFase3 + #663, #3967
  static MapaFase3 + #664, #3967
  static MapaFase3 + #665, #3876
  static MapaFase3 + #666, #1823
  static MapaFase3 + #667, #2084
  static MapaFase3 + #668, #1828
  static MapaFase3 + #669, #2084
  static MapaFase3 + #670, #1828
  static MapaFase3 + #671, #1828
  static MapaFase3 + #672, #2084
  static MapaFase3 + #673, #1828
  static MapaFase3 + #674, #2107
  static MapaFase3 + #675, #3876
  static MapaFase3 + #676, #3967
  static MapaFase3 + #677, #3967
  static MapaFase3 + #678, #3967
  static MapaFase3 + #679, #3967

  ;Linha 17
  static MapaFase3 + #680, #3967
  static MapaFase3 + #681, #3967
  static MapaFase3 + #682, #3967
  static MapaFase3 + #683, #3967
  static MapaFase3 + #684, #3967
  static MapaFase3 + #685, #3967
  static MapaFase3 + #686, #3967
  static MapaFase3 + #687, #3967
  static MapaFase3 + #688, #3967
  static MapaFase3 + #689, #3967
  static MapaFase3 + #690, #3967
  static MapaFase3 + #691, #3967
  static MapaFase3 + #692, #3967
  static MapaFase3 + #693, #3967
  static MapaFase3 + #694, #3967
  static MapaFase3 + #695, #3967
  static MapaFase3 + #696, #3967
  static MapaFase3 + #697, #3967
  static MapaFase3 + #698, #3967
  static MapaFase3 + #699, #3967
  static MapaFase3 + #700, #3967
  static MapaFase3 + #701, #3967
  static MapaFase3 + #702, #3967
  static MapaFase3 + #703, #3967
  static MapaFase3 + #704, #3967
  static MapaFase3 + #705, #3967
  static MapaFase3 + #706, #3876
  static MapaFase3 + #707, #2079
  static MapaFase3 + #708, #1828
  static MapaFase3 + #709, #2084
  static MapaFase3 + #710, #1828
  static MapaFase3 + #711, #1828
  static MapaFase3 + #712, #2084
  static MapaFase3 + #713, #1851
  static MapaFase3 + #714, #3876
  static MapaFase3 + #715, #3967
  static MapaFase3 + #716, #3967
  static MapaFase3 + #717, #3967
  static MapaFase3 + #718, #3967
  static MapaFase3 + #719, #3967

  ;Linha 18
  static MapaFase3 + #720, #3967
  static MapaFase3 + #721, #3967
  static MapaFase3 + #722, #3967
  static MapaFase3 + #723, #3967
  static MapaFase3 + #724, #3967
  static MapaFase3 + #725, #3967
  static MapaFase3 + #726, #3967
  static MapaFase3 + #727, #3967
  static MapaFase3 + #728, #3967
  static MapaFase3 + #729, #3967
  static MapaFase3 + #730, #3967
  static MapaFase3 + #731, #3967
  static MapaFase3 + #732, #3967
  static MapaFase3 + #733, #3967
  static MapaFase3 + #734, #3967
  static MapaFase3 + #735, #3967
  static MapaFase3 + #736, #3967
  static MapaFase3 + #737, #3967
  static MapaFase3 + #738, #3967
  static MapaFase3 + #739, #3967
  static MapaFase3 + #740, #3967
  static MapaFase3 + #741, #3967
  static MapaFase3 + #742, #3967
  static MapaFase3 + #743, #3967
  static MapaFase3 + #744, #3967
  static MapaFase3 + #745, #3967
  static MapaFase3 + #746, #3967
  static MapaFase3 + #747, #3967
  static MapaFase3 + #748, #3967
  static MapaFase3 + #749, #3967
  static MapaFase3 + #750, #3967
  static MapaFase3 + #751, #3967
  static MapaFase3 + #752, #3967
  static MapaFase3 + #753, #3967
  static MapaFase3 + #754, #3967
  static MapaFase3 + #755, #3967
  static MapaFase3 + #756, #3967
  static MapaFase3 + #757, #3967
  static MapaFase3 + #758, #3967
  static MapaFase3 + #759, #3967

  ;Linha 19
  static MapaFase3 + #760, #3967
  static MapaFase3 + #761, #3967
  static MapaFase3 + #762, #3967
  static MapaFase3 + #763, #3967
  static MapaFase3 + #764, #3967
  static MapaFase3 + #765, #3967
  static MapaFase3 + #766, #3967
  static MapaFase3 + #767, #3967
  static MapaFase3 + #768, #3967
  static MapaFase3 + #769, #3967
  static MapaFase3 + #770, #3967
  static MapaFase3 + #771, #3967
  static MapaFase3 + #772, #3967
  static MapaFase3 + #773, #3967
  static MapaFase3 + #774, #3967
  static MapaFase3 + #775, #3904
  static MapaFase3 + #776, #3967
  static MapaFase3 + #777, #3967
  static MapaFase3 + #778, #3967
  static MapaFase3 + #779, #3967
  static MapaFase3 + #780, #3967
  static MapaFase3 + #781, #3967
  static MapaFase3 + #782, #3967
  static MapaFase3 + #783, #3967
  static MapaFase3 + #784, #3967
  static MapaFase3 + #785, #3967
  static MapaFase3 + #786, #3967
  static MapaFase3 + #787, #3967
  static MapaFase3 + #788, #3967
  static MapaFase3 + #789, #3967
  static MapaFase3 + #790, #3967
  static MapaFase3 + #791, #3967
  static MapaFase3 + #792, #3967
  static MapaFase3 + #793, #1067
  static MapaFase3 + #794, #3967
  static MapaFase3 + #795, #3967
  static MapaFase3 + #796, #3967
  static MapaFase3 + #797, #3967
  static MapaFase3 + #798, #3967
  static MapaFase3 + #799, #3967

  ;Linha 20
  static MapaFase3 + #800, #3967
  static MapaFase3 + #801, #3967
  static MapaFase3 + #802, #3967
  static MapaFase3 + #803, #3967
  static MapaFase3 + #804, #3967
  static MapaFase3 + #805, #3967
  static MapaFase3 + #806, #3967
  static MapaFase3 + #807, #3967
  static MapaFase3 + #808, #3967
  static MapaFase3 + #809, #3967
  static MapaFase3 + #810, #3967
  static MapaFase3 + #811, #3967
  static MapaFase3 + #812, #3967
  static MapaFase3 + #813, #3967
  static MapaFase3 + #814, #3967
  static MapaFase3 + #815, #1066
  static MapaFase3 + #816, #3967
  static MapaFase3 + #817, #3967
  static MapaFase3 + #818, #3967
  static MapaFase3 + #819, #3967
  static MapaFase3 + #820, #3967
  static MapaFase3 + #821, #3967
  static MapaFase3 + #822, #3967
  static MapaFase3 + #823, #3967
  static MapaFase3 + #824, #3967
  static MapaFase3 + #825, #3967
  static MapaFase3 + #826, #3967
  static MapaFase3 + #827, #3967
  static MapaFase3 + #828, #3967
  static MapaFase3 + #829, #3967
  static MapaFase3 + #830, #3967
  static MapaFase3 + #831, #3967
  static MapaFase3 + #832, #3967
  static MapaFase3 + #833, #3967
  static MapaFase3 + #834, #3967
  static MapaFase3 + #835, #3967
  static MapaFase3 + #836, #3967
  static MapaFase3 + #837, #3967
  static MapaFase3 + #838, #3967
  static MapaFase3 + #839, #3967

  ;Linha 21
  static MapaFase3 + #840, #3967
  static MapaFase3 + #841, #3967
  static MapaFase3 + #842, #3967
  static MapaFase3 + #843, #3967
  static MapaFase3 + #844, #3967
  static MapaFase3 + #845, #3967
  static MapaFase3 + #846, #3967
  static MapaFase3 + #847, #3967
  static MapaFase3 + #848, #3967
  static MapaFase3 + #849, #3967
  static MapaFase3 + #850, #3967
  static MapaFase3 + #851, #3967
  static MapaFase3 + #852, #3967
  static MapaFase3 + #853, #3967
  static MapaFase3 + #854, #3967
  static MapaFase3 + #855, #3967
  static MapaFase3 + #856, #3967
  static MapaFase3 + #857, #3967
  static MapaFase3 + #858, #3967
  static MapaFase3 + #859, #3967
  static MapaFase3 + #860, #3967
  static MapaFase3 + #861, #3967
  static MapaFase3 + #862, #3967
  static MapaFase3 + #863, #3967
  static MapaFase3 + #864, #3967
  static MapaFase3 + #865, #3967
  static MapaFase3 + #866, #3967
  static MapaFase3 + #867, #3967
  static MapaFase3 + #868, #3967
  static MapaFase3 + #869, #3967
  static MapaFase3 + #870, #3967
  static MapaFase3 + #871, #3967
  static MapaFase3 + #872, #3967
  static MapaFase3 + #873, #3967
  static MapaFase3 + #874, #3967
  static MapaFase3 + #875, #3967
  static MapaFase3 + #876, #3967
  static MapaFase3 + #877, #3967
  static MapaFase3 + #878, #3967
  static MapaFase3 + #879, #3967

  ;Linha 22
  static MapaFase3 + #880, #3967
  static MapaFase3 + #881, #3967
  static MapaFase3 + #882, #3967
  static MapaFase3 + #883, #3967
  static MapaFase3 + #884, #3967
  static MapaFase3 + #885, #3967
  static MapaFase3 + #886, #3967
  static MapaFase3 + #887, #3967
  static MapaFase3 + #888, #3967
  static MapaFase3 + #889, #3967
  static MapaFase3 + #890, #3967
  static MapaFase3 + #891, #3967
  static MapaFase3 + #892, #3967
  static MapaFase3 + #893, #3967
  static MapaFase3 + #894, #3967
  static MapaFase3 + #895, #3967
  static MapaFase3 + #896, #3967
  static MapaFase3 + #897, #3967
  static MapaFase3 + #898, #3967
  static MapaFase3 + #899, #3967
  static MapaFase3 + #900, #3967
  static MapaFase3 + #901, #3967
  static MapaFase3 + #902, #3967
  static MapaFase3 + #903, #3967
  static MapaFase3 + #904, #3967
  static MapaFase3 + #905, #3967
  static MapaFase3 + #906, #3967
  static MapaFase3 + #907, #3967
  static MapaFase3 + #908, #3967
  static MapaFase3 + #909, #3967
  static MapaFase3 + #910, #3967
  static MapaFase3 + #911, #3967
  static MapaFase3 + #912, #3967
  static MapaFase3 + #913, #3967
  static MapaFase3 + #914, #3967
  static MapaFase3 + #915, #3967
  static MapaFase3 + #916, #3967
  static MapaFase3 + #917, #3967
  static MapaFase3 + #918, #3967
  static MapaFase3 + #919, #3967

  ;Linha 23
  static MapaFase3 + #920, #3967
  static MapaFase3 + #921, #3967
  static MapaFase3 + #922, #3967
  static MapaFase3 + #923, #3967
  static MapaFase3 + #924, #3967
  static MapaFase3 + #925, #3967
  static MapaFase3 + #926, #3967
  static MapaFase3 + #927, #3967
  static MapaFase3 + #928, #3967
  static MapaFase3 + #929, #3967
  static MapaFase3 + #930, #3967
  static MapaFase3 + #931, #3967
  static MapaFase3 + #932, #3967
  static MapaFase3 + #933, #3967
  static MapaFase3 + #934, #3967
  static MapaFase3 + #935, #3967
  static MapaFase3 + #936, #3967
  static MapaFase3 + #937, #3967
  static MapaFase3 + #938, #3967
  static MapaFase3 + #939, #3967
  static MapaFase3 + #940, #3967
  static MapaFase3 + #941, #3967
  static MapaFase3 + #942, #3967
  static MapaFase3 + #943, #3967
  static MapaFase3 + #944, #3967
  static MapaFase3 + #945, #3967
  static MapaFase3 + #946, #3967
  static MapaFase3 + #947, #3967
  static MapaFase3 + #948, #3967
  static MapaFase3 + #949, #3967
  static MapaFase3 + #950, #3967
  static MapaFase3 + #951, #3967
  static MapaFase3 + #952, #3967
  static MapaFase3 + #953, #3967
  static MapaFase3 + #954, #3967
  static MapaFase3 + #955, #3967
  static MapaFase3 + #956, #3967
  static MapaFase3 + #957, #3967
  static MapaFase3 + #958, #3967
  static MapaFase3 + #959, #3967

  ;Linha 24
  static MapaFase3 + #960, #1067
  static MapaFase3 + #961, #3967
  static MapaFase3 + #962, #3967
  static MapaFase3 + #963, #3967
  static MapaFase3 + #964, #3967
  static MapaFase3 + #965, #3967
  static MapaFase3 + #966, #3967
  static MapaFase3 + #967, #3967
  static MapaFase3 + #968, #3967
  static MapaFase3 + #969, #3967
  static MapaFase3 + #970, #3967
  static MapaFase3 + #971, #3967
  static MapaFase3 + #972, #3967
  static MapaFase3 + #973, #3967
  static MapaFase3 + #974, #3967
  static MapaFase3 + #975, #3967
  static MapaFase3 + #976, #3967
  static MapaFase3 + #977, #3967
  static MapaFase3 + #978, #3967
  static MapaFase3 + #979, #3967
  static MapaFase3 + #980, #3967
  static MapaFase3 + #981, #3967
  static MapaFase3 + #982, #3967
  static MapaFase3 + #983, #3967
  static MapaFase3 + #984, #3967
  static MapaFase3 + #985, #3967
  static MapaFase3 + #986, #3967
  static MapaFase3 + #987, #3967
  static MapaFase3 + #988, #3967
  static MapaFase3 + #989, #3967
  static MapaFase3 + #990, #3967
  static MapaFase3 + #991, #3967
  static MapaFase3 + #992, #3967
  static MapaFase3 + #993, #3967
  static MapaFase3 + #994, #3967
  static MapaFase3 + #995, #3967
  static MapaFase3 + #996, #3967
  static MapaFase3 + #997, #3967
  static MapaFase3 + #998, #3967
  static MapaFase3 + #999, #3967

  ;Linha 25
  static MapaFase3 + #1000, #3967
  static MapaFase3 + #1001, #3967
  static MapaFase3 + #1002, #3967
  static MapaFase3 + #1003, #3967
  static MapaFase3 + #1004, #3967
  static MapaFase3 + #1005, #3967
  static MapaFase3 + #1006, #3967
  static MapaFase3 + #1007, #3967
  static MapaFase3 + #1008, #3967
  static MapaFase3 + #1009, #3967
  static MapaFase3 + #1010, #3967
  static MapaFase3 + #1011, #3967
  static MapaFase3 + #1012, #3967
  static MapaFase3 + #1013, #3967
  static MapaFase3 + #1014, #3967
  static MapaFase3 + #1015, #3967
  static MapaFase3 + #1016, #3967
  static MapaFase3 + #1017, #3967
  static MapaFase3 + #1018, #3967
  static MapaFase3 + #1019, #3967
  static MapaFase3 + #1020, #3967
  static MapaFase3 + #1021, #3967
  static MapaFase3 + #1022, #3967
  static MapaFase3 + #1023, #3967
  static MapaFase3 + #1024, #3967
  static MapaFase3 + #1025, #3967
  static MapaFase3 + #1026, #3967
  static MapaFase3 + #1027, #3967
  static MapaFase3 + #1028, #3967
  static MapaFase3 + #1029, #3967
  static MapaFase3 + #1030, #3967
  static MapaFase3 + #1031, #3967
  static MapaFase3 + #1032, #3967
  static MapaFase3 + #1033, #3967
  static MapaFase3 + #1034, #3967
  static MapaFase3 + #1035, #3967
  static MapaFase3 + #1036, #3967
  static MapaFase3 + #1037, #3967
  static MapaFase3 + #1038, #3967
  static MapaFase3 + #1039, #3967

  ;Linha 26
  static MapaFase3 + #1040, #3967
  static MapaFase3 + #1041, #3967
  static MapaFase3 + #1042, #3967
  static MapaFase3 + #1043, #3967
  static MapaFase3 + #1044, #3967
  static MapaFase3 + #1045, #3967
  static MapaFase3 + #1046, #3967
  static MapaFase3 + #1047, #3967
  static MapaFase3 + #1048, #3967
  static MapaFase3 + #1049, #3967
  static MapaFase3 + #1050, #3967
  static MapaFase3 + #1051, #3967
  static MapaFase3 + #1052, #3967
  static MapaFase3 + #1053, #3967
  static MapaFase3 + #1054, #3967
  static MapaFase3 + #1055, #3967
  static MapaFase3 + #1056, #3967
  static MapaFase3 + #1057, #3967
  static MapaFase3 + #1058, #3967
  static MapaFase3 + #1059, #3967
  static MapaFase3 + #1060, #3967
  static MapaFase3 + #1061, #3967
  static MapaFase3 + #1062, #3967
  static MapaFase3 + #1063, #3967
  static MapaFase3 + #1064, #3967
  static MapaFase3 + #1065, #3967
  static MapaFase3 + #1066, #3967
  static MapaFase3 + #1067, #3967
  static MapaFase3 + #1068, #1088
  static MapaFase3 + #1069, #3967
  static MapaFase3 + #1070, #3967
  static MapaFase3 + #1071, #3967
  static MapaFase3 + #1072, #3967
  static MapaFase3 + #1073, #3967
  static MapaFase3 + #1074, #3967
  static MapaFase3 + #1075, #3967
  static MapaFase3 + #1076, #3967
  static MapaFase3 + #1077, #3967
  static MapaFase3 + #1078, #3967
  static MapaFase3 + #1079, #3967

  ;Linha 27
  static MapaFase3 + #1080, #3967
  static MapaFase3 + #1081, #3967
  static MapaFase3 + #1082, #3967
  static MapaFase3 + #1083, #3967
  static MapaFase3 + #1084, #3967
  static MapaFase3 + #1085, #3967
  static MapaFase3 + #1086, #3967
  static MapaFase3 + #1087, #3967
  static MapaFase3 + #1088, #3967
  static MapaFase3 + #1089, #3967
  static MapaFase3 + #1090, #3967
  static MapaFase3 + #1091, #3967
  static MapaFase3 + #1092, #3967
  static MapaFase3 + #1093, #3967
  static MapaFase3 + #1094, #3967
  static MapaFase3 + #1095, #3967
  static MapaFase3 + #1096, #3967
  static MapaFase3 + #1097, #3967
  static MapaFase3 + #1098, #3967
  static MapaFase3 + #1099, #3967
  static MapaFase3 + #1100, #3967
  static MapaFase3 + #1101, #3967
  static MapaFase3 + #1102, #3967
  static MapaFase3 + #1103, #3967
  static MapaFase3 + #1104, #3967
  static MapaFase3 + #1105, #3967
  static MapaFase3 + #1106, #3967
  static MapaFase3 + #1107, #3967
  static MapaFase3 + #1108, #3967
  static MapaFase3 + #1109, #3967
  static MapaFase3 + #1110, #3967
  static MapaFase3 + #1111, #3967
  static MapaFase3 + #1112, #3967
  static MapaFase3 + #1113, #3967
  static MapaFase3 + #1114, #3967
  static MapaFase3 + #1115, #3967
  static MapaFase3 + #1116, #3967
  static MapaFase3 + #1117, #3967
  static MapaFase3 + #1118, #3967
  static MapaFase3 + #1119, #3967

  ;Linha 28
  static MapaFase3 + #1120, #3967
  static MapaFase3 + #1121, #3967
  static MapaFase3 + #1122, #3967
  static MapaFase3 + #1123, #3967
  static MapaFase3 + #1124, #3967
  static MapaFase3 + #1125, #3967
  static MapaFase3 + #1126, #3967
  static MapaFase3 + #1127, #3967
  static MapaFase3 + #1128, #3967
  static MapaFase3 + #1129, #3967
  static MapaFase3 + #1130, #3967
  static MapaFase3 + #1131, #3967
  static MapaFase3 + #1132, #3967
  static MapaFase3 + #1133, #3967
  static MapaFase3 + #1134, #3967
  static MapaFase3 + #1135, #3967
  static MapaFase3 + #1136, #3967
  static MapaFase3 + #1137, #3967
  static MapaFase3 + #1138, #3967
  static MapaFase3 + #1139, #3967
  static MapaFase3 + #1140, #3967
  static MapaFase3 + #1141, #3967
  static MapaFase3 + #1142, #3967
  static MapaFase3 + #1143, #3967
  static MapaFase3 + #1144, #3967
  static MapaFase3 + #1145, #3967
  static MapaFase3 + #1146, #3967
  static MapaFase3 + #1147, #3967
  static MapaFase3 + #1148, #3967
  static MapaFase3 + #1149, #3967
  static MapaFase3 + #1150, #3967
  static MapaFase3 + #1151, #3967
  static MapaFase3 + #1152, #3967
  static MapaFase3 + #1153, #3967
  static MapaFase3 + #1154, #3967
  static MapaFase3 + #1155, #3967
  static MapaFase3 + #1156, #3967
  static MapaFase3 + #1157, #3967
  static MapaFase3 + #1158, #3967
  static MapaFase3 + #1159, #3967

  ;Linha 29
  static MapaFase3 + #1160, #3967
  static MapaFase3 + #1161, #3967
  static MapaFase3 + #1162, #3967
  static MapaFase3 + #1163, #3967
  static MapaFase3 + #1164, #3967
  static MapaFase3 + #1165, #3967
  static MapaFase3 + #1166, #3967
  static MapaFase3 + #1167, #3967
  static MapaFase3 + #1168, #3967
  static MapaFase3 + #1169, #3967
  static MapaFase3 + #1170, #3967
  static MapaFase3 + #1171, #3967
  static MapaFase3 + #1172, #3967
  static MapaFase3 + #1173, #3967
  static MapaFase3 + #1174, #3967
  static MapaFase3 + #1175, #3967
  static MapaFase3 + #1176, #3967
  static MapaFase3 + #1177, #3967
  static MapaFase3 + #1178, #3967
  static MapaFase3 + #1179, #3967
  static MapaFase3 + #1180, #3967
  static MapaFase3 + #1181, #3967
  static MapaFase3 + #1182, #3967
  static MapaFase3 + #1183, #3967
  static MapaFase3 + #1184, #3967
  static MapaFase3 + #1185, #3967
  static MapaFase3 + #1186, #3967
  static MapaFase3 + #1187, #3967
  static MapaFase3 + #1188, #3967
  static MapaFase3 + #1189, #3967
  static MapaFase3 + #1190, #3967
  static MapaFase3 + #1191, #3967
  static MapaFase3 + #1192, #3967
  static MapaFase3 + #1193, #3967
  static MapaFase3 + #1194, #3967
  static MapaFase3 + #1195, #3967
  static MapaFase3 + #1196, #3967
  static MapaFase3 + #1197, #3967
  static MapaFase3 + #1198, #3967
  static MapaFase3 + #1199, #3967
  
  
 MapaFase4 : var #1200
  ;Linha 0
  static MapaFase4 + #0, #3967
  static MapaFase4 + #1, #3967
  static MapaFase4 + #2, #3967
  static MapaFase4 + #3, #3967
  static MapaFase4 + #4, #3967
  static MapaFase4 + #5, #3967
  static MapaFase4 + #6, #3967
  static MapaFase4 + #7, #3967
  static MapaFase4 + #8, #3967
  static MapaFase4 + #9, #3967
  static MapaFase4 + #10, #3967
  static MapaFase4 + #11, #3967
  static MapaFase4 + #12, #3967
  static MapaFase4 + #13, #3967
  static MapaFase4 + #14, #3967
  static MapaFase4 + #15, #3967
  static MapaFase4 + #16, #3967
  static MapaFase4 + #17, #3967
  static MapaFase4 + #18, #3967
  static MapaFase4 + #19, #3967
  static MapaFase4 + #20, #3967
  static MapaFase4 + #21, #3967
  static MapaFase4 + #22, #3967
  static MapaFase4 + #23, #3967
  static MapaFase4 + #24, #1824
  static MapaFase4 + #25, #1824
  static MapaFase4 + #26, #3967
  static MapaFase4 + #27, #1824
  static MapaFase4 + #28, #1824
  static MapaFase4 + #29, #2062
  static MapaFase4 + #30, #1799
  static MapaFase4 + #31, #2084
  static MapaFase4 + #32, #2084
  static MapaFase4 + #33, #2084
  static MapaFase4 + #34, #1828
  static MapaFase4 + #35, #1828
  static MapaFase4 + #36, #2084
  static MapaFase4 + #37, #2084
  static MapaFase4 + #38, #2084
  static MapaFase4 + #39, #1828

  ;Linha 1
  static MapaFase4 + #40, #3967
  static MapaFase4 + #41, #3967
  static MapaFase4 + #42, #3967
  static MapaFase4 + #43, #3967
  static MapaFase4 + #44, #3967
  static MapaFase4 + #45, #3967
  static MapaFase4 + #46, #3967
  static MapaFase4 + #47, #3967
  static MapaFase4 + #48, #3967
  static MapaFase4 + #49, #3967
  static MapaFase4 + #50, #3967
  static MapaFase4 + #51, #3967
  static MapaFase4 + #52, #3967
  static MapaFase4 + #53, #3967
  static MapaFase4 + #54, #3967
  static MapaFase4 + #55, #3967
  static MapaFase4 + #56, #3967
  static MapaFase4 + #57, #3967
  static MapaFase4 + #58, #3967
  static MapaFase4 + #59, #3967
  static MapaFase4 + #60, #3967
  static MapaFase4 + #61, #3967
  static MapaFase4 + #62, #3967
  static MapaFase4 + #63, #1824
  static MapaFase4 + #64, #1824
  static MapaFase4 + #65, #3967
  static MapaFase4 + #66, #1824
  static MapaFase4 + #67, #1824
  static MapaFase4 + #68, #2049
  static MapaFase4 + #69, #2084
  static MapaFase4 + #70, #1828
  static MapaFase4 + #71, #2084
  static MapaFase4 + #72, #2084
  static MapaFase4 + #73, #2084
  static MapaFase4 + #74, #1828
  static MapaFase4 + #75, #1828
  static MapaFase4 + #76, #2084
  static MapaFase4 + #77, #2084
  static MapaFase4 + #78, #2084
  static MapaFase4 + #79, #1828

  ;Linha 2
  static MapaFase4 + #80, #3967
  static MapaFase4 + #81, #3967
  static MapaFase4 + #82, #3967
  static MapaFase4 + #83, #3967
  static MapaFase4 + #84, #3967
  static MapaFase4 + #85, #3967
  static MapaFase4 + #86, #3967
  static MapaFase4 + #87, #3967
  static MapaFase4 + #88, #3967
  static MapaFase4 + #89, #3967
  static MapaFase4 + #90, #3967
  static MapaFase4 + #91, #3967
  static MapaFase4 + #92, #3967
  static MapaFase4 + #93, #3967
  static MapaFase4 + #94, #3967
  static MapaFase4 + #95, #3967
  static MapaFase4 + #96, #3967
  static MapaFase4 + #97, #3967
  static MapaFase4 + #98, #3967
  static MapaFase4 + #99, #3967
  static MapaFase4 + #100, #3967
  static MapaFase4 + #101, #3967
  static MapaFase4 + #102, #3967
  static MapaFase4 + #103, #3967
  static MapaFase4 + #104, #3967
  static MapaFase4 + #105, #1824
  static MapaFase4 + #106, #1824
  static MapaFase4 + #107, #2049
  static MapaFase4 + #108, #2084
  static MapaFase4 + #109, #2084
  static MapaFase4 + #110, #1828
  static MapaFase4 + #111, #1828
  static MapaFase4 + #112, #1828
  static MapaFase4 + #113, #1828
  static MapaFase4 + #114, #1828
  static MapaFase4 + #115, #1828
  static MapaFase4 + #116, #2084
  static MapaFase4 + #117, #2084
  static MapaFase4 + #118, #2084
  static MapaFase4 + #119, #1828

  ;Linha 3
  static MapaFase4 + #120, #3967
  static MapaFase4 + #121, #3967
  static MapaFase4 + #122, #3967
  static MapaFase4 + #123, #3967
  static MapaFase4 + #124, #3967
  static MapaFase4 + #125, #3967
  static MapaFase4 + #126, #3967
  static MapaFase4 + #127, #3967
  static MapaFase4 + #128, #3967
  static MapaFase4 + #129, #3967
  static MapaFase4 + #130, #3967
  static MapaFase4 + #131, #3967
  static MapaFase4 + #132, #3967
  static MapaFase4 + #133, #3967
  static MapaFase4 + #134, #3967
  static MapaFase4 + #135, #3967
  static MapaFase4 + #136, #3967
  static MapaFase4 + #137, #3967
  static MapaFase4 + #138, #3967
  static MapaFase4 + #139, #3967
  static MapaFase4 + #140, #3967
  static MapaFase4 + #141, #3967
  static MapaFase4 + #142, #3967
  static MapaFase4 + #143, #3967
  static MapaFase4 + #144, #3967
  static MapaFase4 + #145, #1824
  static MapaFase4 + #146, #1793
  static MapaFase4 + #147, #2084
  static MapaFase4 + #148, #2084
  static MapaFase4 + #149, #2084
  static MapaFase4 + #150, #1828
  static MapaFase4 + #151, #2084
  static MapaFase4 + #152, #2084
  static MapaFase4 + #153, #2084
  static MapaFase4 + #154, #1828
  static MapaFase4 + #155, #1828
  static MapaFase4 + #156, #2084
  static MapaFase4 + #157, #2084
  static MapaFase4 + #158, #2084
  static MapaFase4 + #159, #1828

  ;Linha 4
  static MapaFase4 + #160, #3967
  static MapaFase4 + #161, #3967
  static MapaFase4 + #162, #3967
  static MapaFase4 + #163, #3967
  static MapaFase4 + #164, #3967
  static MapaFase4 + #165, #3967
  static MapaFase4 + #166, #3967
  static MapaFase4 + #167, #3967
  static MapaFase4 + #168, #3967
  static MapaFase4 + #169, #3967
  static MapaFase4 + #170, #3967
  static MapaFase4 + #171, #3967
  static MapaFase4 + #172, #3967
  static MapaFase4 + #173, #3967
  static MapaFase4 + #174, #3967
  static MapaFase4 + #175, #3967
  static MapaFase4 + #176, #3967
  static MapaFase4 + #177, #3967
  static MapaFase4 + #178, #3967
  static MapaFase4 + #179, #3967
  static MapaFase4 + #180, #3967
  static MapaFase4 + #181, #3967
  static MapaFase4 + #182, #3967
  static MapaFase4 + #183, #3967
  static MapaFase4 + #184, #3967
  static MapaFase4 + #185, #1807
  static MapaFase4 + #186, #1828
  static MapaFase4 + #187, #2084
  static MapaFase4 + #188, #2084
  static MapaFase4 + #189, #2084
  static MapaFase4 + #190, #1828
  static MapaFase4 + #191, #2084
  static MapaFase4 + #192, #2084
  static MapaFase4 + #193, #2084
  static MapaFase4 + #194, #1828
  static MapaFase4 + #195, #1828
  static MapaFase4 + #196, #1828
  static MapaFase4 + #197, #1828
  static MapaFase4 + #198, #1828
  static MapaFase4 + #199, #1828

  ;Linha 5
  static MapaFase4 + #200, #3967
  static MapaFase4 + #201, #3967
  static MapaFase4 + #202, #3967
  static MapaFase4 + #203, #3967
  static MapaFase4 + #204, #1088
  static MapaFase4 + #205, #3967
  static MapaFase4 + #206, #3967
  static MapaFase4 + #207, #3967
  static MapaFase4 + #208, #3967
  static MapaFase4 + #209, #3967
  static MapaFase4 + #210, #3967
  static MapaFase4 + #211, #3967
  static MapaFase4 + #212, #3967
  static MapaFase4 + #213, #3967
  static MapaFase4 + #214, #3967
  static MapaFase4 + #215, #3967
  static MapaFase4 + #216, #3967
  static MapaFase4 + #217, #3967
  static MapaFase4 + #218, #3967
  static MapaFase4 + #219, #3967
  static MapaFase4 + #220, #3967
  static MapaFase4 + #221, #3967
  static MapaFase4 + #222, #3967
  static MapaFase4 + #223, #3967
  static MapaFase4 + #224, #1824
  static MapaFase4 + #225, #1808
  static MapaFase4 + #226, #1828
  static MapaFase4 + #227, #1828
  static MapaFase4 + #228, #1828
  static MapaFase4 + #229, #1828
  static MapaFase4 + #230, #1828
  static MapaFase4 + #231, #2084
  static MapaFase4 + #232, #2084
  static MapaFase4 + #233, #2084
  static MapaFase4 + #234, #1828
  static MapaFase4 + #235, #1828
  static MapaFase4 + #236, #2084
  static MapaFase4 + #237, #2084
  static MapaFase4 + #238, #2084
  static MapaFase4 + #239, #1828

  ;Linha 6
  static MapaFase4 + #240, #3967
  static MapaFase4 + #241, #3967
  static MapaFase4 + #242, #3967
  static MapaFase4 + #243, #3967
  static MapaFase4 + #244, #3967
  static MapaFase4 + #245, #3967
  static MapaFase4 + #246, #3967
  static MapaFase4 + #247, #3967
  static MapaFase4 + #248, #3967
  static MapaFase4 + #249, #3967
  static MapaFase4 + #250, #3967
  static MapaFase4 + #251, #3967
  static MapaFase4 + #252, #3967
  static MapaFase4 + #253, #3967
  static MapaFase4 + #254, #3967
  static MapaFase4 + #255, #3967
  static MapaFase4 + #256, #3967
  static MapaFase4 + #257, #3967
  static MapaFase4 + #258, #3967
  static MapaFase4 + #259, #3967
  static MapaFase4 + #260, #3967
  static MapaFase4 + #261, #3967
  static MapaFase4 + #262, #3967
  static MapaFase4 + #263, #3876
  static MapaFase4 + #264, #1809
  static MapaFase4 + #265, #1828
  static MapaFase4 + #266, #1828
  static MapaFase4 + #267, #2084
  static MapaFase4 + #268, #2084
  static MapaFase4 + #269, #2121
  static MapaFase4 + #270, #2131
  static MapaFase4 + #271, #2123
  static MapaFase4 + #272, #2137
  static MapaFase4 + #273, #2138
  static MapaFase4 + #274, #1828
  static MapaFase4 + #275, #1828
  static MapaFase4 + #276, #2084
  static MapaFase4 + #277, #2084
  static MapaFase4 + #278, #2084
  static MapaFase4 + #279, #1828

  ;Linha 7
  static MapaFase4 + #280, #3967
  static MapaFase4 + #281, #3967
  static MapaFase4 + #282, #3967
  static MapaFase4 + #283, #3967
  static MapaFase4 + #284, #3967
  static MapaFase4 + #285, #3967
  static MapaFase4 + #286, #3967
  static MapaFase4 + #287, #3967
  static MapaFase4 + #288, #3967
  static MapaFase4 + #289, #3967
  static MapaFase4 + #290, #3967
  static MapaFase4 + #291, #3967
  static MapaFase4 + #292, #3967
  static MapaFase4 + #293, #3967
  static MapaFase4 + #294, #3967
  static MapaFase4 + #295, #3967
  static MapaFase4 + #296, #3967
  static MapaFase4 + #297, #3967
  static MapaFase4 + #298, #3967
  static MapaFase4 + #299, #3967
  static MapaFase4 + #300, #3967
  static MapaFase4 + #301, #3967
  static MapaFase4 + #302, #3876
  static MapaFase4 + #303, #1824
  static MapaFase4 + #304, #1810
  static MapaFase4 + #305, #1828
  static MapaFase4 + #306, #1828
  static MapaFase4 + #307, #2084
  static MapaFase4 + #308, #2126
  static MapaFase4 + #309, #2113
  static MapaFase4 + #310, #2084
  static MapaFase4 + #311, #2117
  static MapaFase4 + #312, #2084
  static MapaFase4 + #313, #2122
  static MapaFase4 + #314, #2136
  static MapaFase4 + #315, #1828
  static MapaFase4 + #316, #1828
  static MapaFase4 + #317, #1828
  static MapaFase4 + #318, #1828
  static MapaFase4 + #319, #1828

  ;Linha 8
  static MapaFase4 + #320, #3967
  static MapaFase4 + #321, #3967
  static MapaFase4 + #322, #3967
  static MapaFase4 + #323, #3967
  static MapaFase4 + #324, #3967
  static MapaFase4 + #325, #3967
  static MapaFase4 + #326, #3967
  static MapaFase4 + #327, #3967
  static MapaFase4 + #328, #3967
  static MapaFase4 + #329, #3967
  static MapaFase4 + #330, #3967
  static MapaFase4 + #331, #3967
  static MapaFase4 + #332, #3967
  static MapaFase4 + #333, #3967
  static MapaFase4 + #334, #3967
  static MapaFase4 + #335, #3967
  static MapaFase4 + #336, #3967
  static MapaFase4 + #337, #3967
  static MapaFase4 + #338, #3967
  static MapaFase4 + #339, #3967
  static MapaFase4 + #340, #3967
  static MapaFase4 + #341, #3967
  static MapaFase4 + #342, #3967
  static MapaFase4 + #343, #1824
  static MapaFase4 + #344, #1811
  static MapaFase4 + #345, #1828
  static MapaFase4 + #346, #1828
  static MapaFase4 + #347, #2084
  static MapaFase4 + #348, #2118
  static MapaFase4 + #349, #2084
  static MapaFase4 + #350, #2071
  static MapaFase4 + #351, #2139
  static MapaFase4 + #352, #2068
  static MapaFase4 + #353, #2084
  static MapaFase4 + #354, #2135
  static MapaFase4 + #355, #1828
  static MapaFase4 + #356, #2084
  static MapaFase4 + #357, #2084
  static MapaFase4 + #358, #2084
  static MapaFase4 + #359, #1828

  ;Linha 9
  static MapaFase4 + #360, #3967
  static MapaFase4 + #361, #3967
  static MapaFase4 + #362, #3967
  static MapaFase4 + #363, #3967
  static MapaFase4 + #364, #3967
  static MapaFase4 + #365, #3967
  static MapaFase4 + #366, #3967
  static MapaFase4 + #367, #3967
  static MapaFase4 + #368, #3967
  static MapaFase4 + #369, #3967
  static MapaFase4 + #370, #3967
  static MapaFase4 + #371, #3967
  static MapaFase4 + #372, #1067
  static MapaFase4 + #373, #3967
  static MapaFase4 + #374, #3967
  static MapaFase4 + #375, #3967
  static MapaFase4 + #376, #3967
  static MapaFase4 + #377, #3967
  static MapaFase4 + #378, #3967
  static MapaFase4 + #379, #3967
  static MapaFase4 + #380, #3967
  static MapaFase4 + #381, #3967
  static MapaFase4 + #382, #3967
  static MapaFase4 + #383, #2063
  static MapaFase4 + #384, #2084
  static MapaFase4 + #385, #2084
  static MapaFase4 + #386, #1828
  static MapaFase4 + #387, #2084
  static MapaFase4 + #388, #2119
  static MapaFase4 + #389, #2125
  static MapaFase4 + #390, #2172
  static MapaFase4 + #391, #2127
  static MapaFase4 + #392, #2173
  static MapaFase4 + #393, #2125
  static MapaFase4 + #394, #2115
  static MapaFase4 + #395, #1828
  static MapaFase4 + #396, #2084
  static MapaFase4 + #397, #2084
  static MapaFase4 + #398, #2084
  static MapaFase4 + #399, #1828

  ;Linha 10
  static MapaFase4 + #400, #3967
  static MapaFase4 + #401, #3967
  static MapaFase4 + #402, #3967
  static MapaFase4 + #403, #3967
  static MapaFase4 + #404, #3967
  static MapaFase4 + #405, #3967
  static MapaFase4 + #406, #3967
  static MapaFase4 + #407, #3967
  static MapaFase4 + #408, #3967
  static MapaFase4 + #409, #3967
  static MapaFase4 + #410, #3967
  static MapaFase4 + #411, #3967
  static MapaFase4 + #412, #3967
  static MapaFase4 + #413, #3967
  static MapaFase4 + #414, #3967
  static MapaFase4 + #415, #3967
  static MapaFase4 + #416, #3967
  static MapaFase4 + #417, #3967
  static MapaFase4 + #418, #3967
  static MapaFase4 + #419, #3967
  static MapaFase4 + #420, #3967
  static MapaFase4 + #421, #3967
  static MapaFase4 + #422, #3967
  static MapaFase4 + #423, #2066
  static MapaFase4 + #424, #2084
  static MapaFase4 + #425, #2084
  static MapaFase4 + #426, #1828
  static MapaFase4 + #427, #2084
  static MapaFase4 + #428, #2120
  static MapaFase4 + #429, #2084
  static MapaFase4 + #430, #2070
  static MapaFase4 + #431, #2171
  static MapaFase4 + #432, #2069
  static MapaFase4 + #433, #2084
  static MapaFase4 + #434, #2134
  static MapaFase4 + #435, #1828
  static MapaFase4 + #436, #2084
  static MapaFase4 + #437, #2084
  static MapaFase4 + #438, #2084
  static MapaFase4 + #439, #1828

  ;Linha 11
  static MapaFase4 + #440, #3967
  static MapaFase4 + #441, #3967
  static MapaFase4 + #442, #3967
  static MapaFase4 + #443, #3967
  static MapaFase4 + #444, #3967
  static MapaFase4 + #445, #3967
  static MapaFase4 + #446, #3967
  static MapaFase4 + #447, #3967
  static MapaFase4 + #448, #3967
  static MapaFase4 + #449, #3967
  static MapaFase4 + #450, #3967
  static MapaFase4 + #451, #3967
  static MapaFase4 + #452, #3967
  static MapaFase4 + #453, #3967
  static MapaFase4 + #454, #3967
  static MapaFase4 + #455, #3967
  static MapaFase4 + #456, #3967
  static MapaFase4 + #457, #3967
  static MapaFase4 + #458, #3967
  static MapaFase4 + #459, #3967
  static MapaFase4 + #460, #3967
  static MapaFase4 + #461, #3967
  static MapaFase4 + #462, #3967
  static MapaFase4 + #463, #2067
  static MapaFase4 + #464, #2084
  static MapaFase4 + #465, #2084
  static MapaFase4 + #466, #1828
  static MapaFase4 + #467, #2084
  static MapaFase4 + #468, #2128
  static MapaFase4 + #469, #2114
  static MapaFase4 + #470, #2084
  static MapaFase4 + #471, #2117
  static MapaFase4 + #472, #2084
  static MapaFase4 + #473, #2116
  static MapaFase4 + #474, #2133
  static MapaFase4 + #475, #1828
  static MapaFase4 + #476, #2084
  static MapaFase4 + #477, #2084
  static MapaFase4 + #478, #2084
  static MapaFase4 + #479, #1828

  ;Linha 12
  static MapaFase4 + #480, #3967
  static MapaFase4 + #481, #3967
  static MapaFase4 + #482, #3967
  static MapaFase4 + #483, #3967
  static MapaFase4 + #484, #3967
  static MapaFase4 + #485, #3967
  static MapaFase4 + #486, #3967
  static MapaFase4 + #487, #3967
  static MapaFase4 + #488, #3967
  static MapaFase4 + #489, #3967
  static MapaFase4 + #490, #3967
  static MapaFase4 + #491, #3967
  static MapaFase4 + #492, #3967
  static MapaFase4 + #493, #3967
  static MapaFase4 + #494, #3967
  static MapaFase4 + #495, #3967
  static MapaFase4 + #496, #3967
  static MapaFase4 + #497, #3967
  static MapaFase4 + #498, #3967
  static MapaFase4 + #499, #3967
  static MapaFase4 + #500, #3967
  static MapaFase4 + #501, #3967
  static MapaFase4 + #502, #3876
  static MapaFase4 + #503, #2084
  static MapaFase4 + #504, #2084
  static MapaFase4 + #505, #2084
  static MapaFase4 + #506, #1828
  static MapaFase4 + #507, #2084
  static MapaFase4 + #508, #2084
  static MapaFase4 + #509, #2130
  static MapaFase4 + #510, #2129
  static MapaFase4 + #511, #2054
  static MapaFase4 + #512, #2131
  static MapaFase4 + #513, #2132
  static MapaFase4 + #514, #1828
  static MapaFase4 + #515, #1828
  static MapaFase4 + #516, #2084
  static MapaFase4 + #517, #2084
  static MapaFase4 + #518, #2084
  static MapaFase4 + #519, #1828

  ;Linha 13
  static MapaFase4 + #520, #3967
  static MapaFase4 + #521, #3967
  static MapaFase4 + #522, #3967
  static MapaFase4 + #523, #3967
  static MapaFase4 + #524, #3967
  static MapaFase4 + #525, #3967
  static MapaFase4 + #526, #3967
  static MapaFase4 + #527, #3967
  static MapaFase4 + #528, #3967
  static MapaFase4 + #529, #3967
  static MapaFase4 + #530, #3967
  static MapaFase4 + #531, #3967
  static MapaFase4 + #532, #3967
  static MapaFase4 + #533, #3967
  static MapaFase4 + #534, #3967
  static MapaFase4 + #535, #3967
  static MapaFase4 + #536, #3967
  static MapaFase4 + #537, #3967
  static MapaFase4 + #538, #3967
  static MapaFase4 + #539, #3967
  static MapaFase4 + #540, #3967
  static MapaFase4 + #541, #3967
  static MapaFase4 + #542, #3876
  static MapaFase4 + #543, #2084
  static MapaFase4 + #544, #2084
  static MapaFase4 + #545, #2084
  static MapaFase4 + #546, #1828
  static MapaFase4 + #547, #2084
  static MapaFase4 + #548, #2084
  static MapaFase4 + #549, #2084
  static MapaFase4 + #550, #1828
  static MapaFase4 + #551, #2084
  static MapaFase4 + #552, #2084
  static MapaFase4 + #553, #2084
  static MapaFase4 + #554, #1828
  static MapaFase4 + #555, #1828
  static MapaFase4 + #556, #2084
  static MapaFase4 + #557, #2084
  static MapaFase4 + #558, #2084
  static MapaFase4 + #559, #1828

  ;Linha 14
  static MapaFase4 + #560, #3967
  static MapaFase4 + #561, #3967
  static MapaFase4 + #562, #3967
  static MapaFase4 + #563, #3967
  static MapaFase4 + #564, #3967
  static MapaFase4 + #565, #3967
  static MapaFase4 + #566, #3967
  static MapaFase4 + #567, #3967
  static MapaFase4 + #568, #3967
  static MapaFase4 + #569, #3967
  static MapaFase4 + #570, #3967
  static MapaFase4 + #571, #3967
  static MapaFase4 + #572, #3967
  static MapaFase4 + #573, #3967
  static MapaFase4 + #574, #3967
  static MapaFase4 + #575, #3967
  static MapaFase4 + #576, #3967
  static MapaFase4 + #577, #3967
  static MapaFase4 + #578, #3967
  static MapaFase4 + #579, #3967
  static MapaFase4 + #580, #3967
  static MapaFase4 + #581, #3967
  static MapaFase4 + #582, #3876
  static MapaFase4 + #583, #2084
  static MapaFase4 + #584, #2084
  static MapaFase4 + #585, #2084
  static MapaFase4 + #586, #1828
  static MapaFase4 + #587, #2084
  static MapaFase4 + #588, #2084
  static MapaFase4 + #589, #2084
  static MapaFase4 + #590, #1828
  static MapaFase4 + #591, #2084
  static MapaFase4 + #592, #2084
  static MapaFase4 + #593, #2084
  static MapaFase4 + #594, #1828
  static MapaFase4 + #595, #1828
  static MapaFase4 + #596, #2084
  static MapaFase4 + #597, #2084
  static MapaFase4 + #598, #2084
  static MapaFase4 + #599, #1828

  ;Linha 15
  static MapaFase4 + #600, #3967
  static MapaFase4 + #601, #3967
  static MapaFase4 + #602, #3967
  static MapaFase4 + #603, #3967
  static MapaFase4 + #604, #3967
  static MapaFase4 + #605, #3967
  static MapaFase4 + #606, #3967
  static MapaFase4 + #607, #3967
  static MapaFase4 + #608, #3967
  static MapaFase4 + #609, #3967
  static MapaFase4 + #610, #3967
  static MapaFase4 + #611, #3967
  static MapaFase4 + #612, #3967
  static MapaFase4 + #613, #3967
  static MapaFase4 + #614, #3967
  static MapaFase4 + #615, #3967
  static MapaFase4 + #616, #3967
  static MapaFase4 + #617, #3967
  static MapaFase4 + #618, #3967
  static MapaFase4 + #619, #3967
  static MapaFase4 + #620, #3967
  static MapaFase4 + #621, #3876
  static MapaFase4 + #622, #3876
  static MapaFase4 + #623, #2084
  static MapaFase4 + #624, #2084
  static MapaFase4 + #625, #2084
  static MapaFase4 + #626, #2084
  static MapaFase4 + #627, #2084
  static MapaFase4 + #628, #2084
  static MapaFase4 + #629, #2084
  static MapaFase4 + #630, #2084
  static MapaFase4 + #631, #2084
  static MapaFase4 + #632, #2084
  static MapaFase4 + #633, #2084
  static MapaFase4 + #634, #2084
  static MapaFase4 + #635, #2084
  static MapaFase4 + #636, #2084
  static MapaFase4 + #637, #2084
  static MapaFase4 + #638, #2084
  static MapaFase4 + #639, #2084

  ;Linha 16
  static MapaFase4 + #640, #3967
  static MapaFase4 + #641, #3967
  static MapaFase4 + #642, #3967
  static MapaFase4 + #643, #3967
  static MapaFase4 + #644, #3967
  static MapaFase4 + #645, #3967
  static MapaFase4 + #646, #3967
  static MapaFase4 + #647, #3967
  static MapaFase4 + #648, #3967
  static MapaFase4 + #649, #3967
  static MapaFase4 + #650, #3967
  static MapaFase4 + #651, #3967
  static MapaFase4 + #652, #3967
  static MapaFase4 + #653, #3967
  static MapaFase4 + #654, #3967
  static MapaFase4 + #655, #3967
  static MapaFase4 + #656, #3967
  static MapaFase4 + #657, #3967
  static MapaFase4 + #658, #3967
  static MapaFase4 + #659, #3967
  static MapaFase4 + #660, #3967
  static MapaFase4 + #661, #3876
  static MapaFase4 + #662, #3876
  static MapaFase4 + #663, #2124
  static MapaFase4 + #664, #2124
  static MapaFase4 + #665, #2124
  static MapaFase4 + #666, #2124
  static MapaFase4 + #667, #2124
  static MapaFase4 + #668, #2124
  static MapaFase4 + #669, #2124
  static MapaFase4 + #670, #2124
  static MapaFase4 + #671, #2124
  static MapaFase4 + #672, #2124
  static MapaFase4 + #673, #2124
  static MapaFase4 + #674, #2124
  static MapaFase4 + #675, #2124
  static MapaFase4 + #676, #2124
  static MapaFase4 + #677, #2124
  static MapaFase4 + #678, #2124
  static MapaFase4 + #679, #2124

  ;Linha 17
  static MapaFase4 + #680, #3967
  static MapaFase4 + #681, #3967
  static MapaFase4 + #682, #3967
  static MapaFase4 + #683, #3967
  static MapaFase4 + #684, #3967
  static MapaFase4 + #685, #3967
  static MapaFase4 + #686, #3967
  static MapaFase4 + #687, #3967
  static MapaFase4 + #688, #3967
  static MapaFase4 + #689, #3967
  static MapaFase4 + #690, #3967
  static MapaFase4 + #691, #3967
  static MapaFase4 + #692, #3967
  static MapaFase4 + #693, #3967
  static MapaFase4 + #694, #3967
  static MapaFase4 + #695, #3967
  static MapaFase4 + #696, #3967
  static MapaFase4 + #697, #3967
  static MapaFase4 + #698, #3967
  static MapaFase4 + #699, #3967
  static MapaFase4 + #700, #3967
  static MapaFase4 + #701, #3876
  static MapaFase4 + #702, #3876
  static MapaFase4 + #703, #2084
  static MapaFase4 + #704, #2084
  static MapaFase4 + #705, #2084
  static MapaFase4 + #706, #2084
  static MapaFase4 + #707, #2084
  static MapaFase4 + #708, #2084
  static MapaFase4 + #709, #2084
  static MapaFase4 + #710, #2084
  static MapaFase4 + #711, #2084
  static MapaFase4 + #712, #2084
  static MapaFase4 + #713, #2084
  static MapaFase4 + #714, #2084
  static MapaFase4 + #715, #2084
  static MapaFase4 + #716, #2084
  static MapaFase4 + #717, #2084
  static MapaFase4 + #718, #2084
  static MapaFase4 + #719, #2084

  ;Linha 18
  static MapaFase4 + #720, #3967
  static MapaFase4 + #721, #3967
  static MapaFase4 + #722, #3967
  static MapaFase4 + #723, #3967
  static MapaFase4 + #724, #3967
  static MapaFase4 + #725, #3967
  static MapaFase4 + #726, #3967
  static MapaFase4 + #727, #3967
  static MapaFase4 + #728, #3967
  static MapaFase4 + #729, #3967
  static MapaFase4 + #730, #3967
  static MapaFase4 + #731, #3967
  static MapaFase4 + #732, #3967
  static MapaFase4 + #733, #3967
  static MapaFase4 + #734, #3967
  static MapaFase4 + #735, #3967
  static MapaFase4 + #736, #3967
  static MapaFase4 + #737, #3967
  static MapaFase4 + #738, #3967
  static MapaFase4 + #739, #3967
  static MapaFase4 + #740, #3967
  static MapaFase4 + #741, #3876
  static MapaFase4 + #742, #3876
  static MapaFase4 + #743, #1804
  static MapaFase4 + #744, #2084
  static MapaFase4 + #745, #2084
  static MapaFase4 + #746, #2084
  static MapaFase4 + #747, #1828
  static MapaFase4 + #748, #1828
  static MapaFase4 + #749, #2084
  static MapaFase4 + #750, #2084
  static MapaFase4 + #751, #2084
  static MapaFase4 + #752, #1828
  static MapaFase4 + #753, #1828
  static MapaFase4 + #754, #1828
  static MapaFase4 + #755, #2084
  static MapaFase4 + #756, #2084
  static MapaFase4 + #757, #2084
  static MapaFase4 + #758, #1828
  static MapaFase4 + #759, #1828

  ;Linha 19
  static MapaFase4 + #760, #3967
  static MapaFase4 + #761, #3967
  static MapaFase4 + #762, #3967
  static MapaFase4 + #763, #3967
  static MapaFase4 + #764, #3967
  static MapaFase4 + #765, #3967
  static MapaFase4 + #766, #3967
  static MapaFase4 + #767, #3967
  static MapaFase4 + #768, #3967
  static MapaFase4 + #769, #3967
  static MapaFase4 + #770, #3967
  static MapaFase4 + #771, #3967
  static MapaFase4 + #772, #3967
  static MapaFase4 + #773, #3967
  static MapaFase4 + #774, #3967
  static MapaFase4 + #775, #3904
  static MapaFase4 + #776, #3967
  static MapaFase4 + #777, #3967
  static MapaFase4 + #778, #3967
  static MapaFase4 + #779, #3967
  static MapaFase4 + #780, #3967
  static MapaFase4 + #781, #3967
  static MapaFase4 + #782, #3876
  static MapaFase4 + #783, #1803
  static MapaFase4 + #784, #2084
  static MapaFase4 + #785, #2084
  static MapaFase4 + #786, #2084
  static MapaFase4 + #787, #1828
  static MapaFase4 + #788, #1828
  static MapaFase4 + #789, #2084
  static MapaFase4 + #790, #2084
  static MapaFase4 + #791, #2084
  static MapaFase4 + #792, #1828
  static MapaFase4 + #793, #1828
  static MapaFase4 + #794, #1828
  static MapaFase4 + #795, #2084
  static MapaFase4 + #796, #2084
  static MapaFase4 + #797, #2084
  static MapaFase4 + #798, #1828
  static MapaFase4 + #799, #1828

  ;Linha 20
  static MapaFase4 + #800, #3967
  static MapaFase4 + #801, #3967
  static MapaFase4 + #802, #3967
  static MapaFase4 + #803, #3967
  static MapaFase4 + #804, #3967
  static MapaFase4 + #805, #3967
  static MapaFase4 + #806, #3967
  static MapaFase4 + #807, #3967
  static MapaFase4 + #808, #3967
  static MapaFase4 + #809, #3967
  static MapaFase4 + #810, #3967
  static MapaFase4 + #811, #3967
  static MapaFase4 + #812, #3967
  static MapaFase4 + #813, #3967
  static MapaFase4 + #814, #3967
  static MapaFase4 + #815, #1066
  static MapaFase4 + #816, #3967
  static MapaFase4 + #817, #3967
  static MapaFase4 + #818, #3967
  static MapaFase4 + #819, #3967
  static MapaFase4 + #820, #3967
  static MapaFase4 + #821, #3967
  static MapaFase4 + #822, #3876
  static MapaFase4 + #823, #3876
  static MapaFase4 + #824, #2060
  static MapaFase4 + #825, #2084
  static MapaFase4 + #826, #2084
  static MapaFase4 + #827, #1828
  static MapaFase4 + #828, #1828
  static MapaFase4 + #829, #2084
  static MapaFase4 + #830, #2084
  static MapaFase4 + #831, #2084
  static MapaFase4 + #832, #1828
  static MapaFase4 + #833, #1828
  static MapaFase4 + #834, #1828
  static MapaFase4 + #835, #2084
  static MapaFase4 + #836, #2084
  static MapaFase4 + #837, #2084
  static MapaFase4 + #838, #1828
  static MapaFase4 + #839, #1828

  ;Linha 21
  static MapaFase4 + #840, #3967
  static MapaFase4 + #841, #3967
  static MapaFase4 + #842, #3967
  static MapaFase4 + #843, #3967
  static MapaFase4 + #844, #3967
  static MapaFase4 + #845, #3967
  static MapaFase4 + #846, #3967
  static MapaFase4 + #847, #3967
  static MapaFase4 + #848, #3967
  static MapaFase4 + #849, #3967
  static MapaFase4 + #850, #3967
  static MapaFase4 + #851, #3967
  static MapaFase4 + #852, #3967
  static MapaFase4 + #853, #3967
  static MapaFase4 + #854, #3967
  static MapaFase4 + #855, #3967
  static MapaFase4 + #856, #3967
  static MapaFase4 + #857, #3967
  static MapaFase4 + #858, #3967
  static MapaFase4 + #859, #3967
  static MapaFase4 + #860, #3967
  static MapaFase4 + #861, #3967
  static MapaFase4 + #862, #3967
  static MapaFase4 + #863, #3876
  static MapaFase4 + #864, #2059
  static MapaFase4 + #865, #2084
  static MapaFase4 + #866, #2084
  static MapaFase4 + #867, #1828
  static MapaFase4 + #868, #1828
  static MapaFase4 + #869, #2084
  static MapaFase4 + #870, #2084
  static MapaFase4 + #871, #2084
  static MapaFase4 + #872, #1828
  static MapaFase4 + #873, #1828
  static MapaFase4 + #874, #1828
  static MapaFase4 + #875, #2084
  static MapaFase4 + #876, #2084
  static MapaFase4 + #877, #2084
  static MapaFase4 + #878, #1828
  static MapaFase4 + #879, #1828

  ;Linha 22
  static MapaFase4 + #880, #3967
  static MapaFase4 + #881, #3967
  static MapaFase4 + #882, #3967
  static MapaFase4 + #883, #3967
  static MapaFase4 + #884, #3967
  static MapaFase4 + #885, #3967
  static MapaFase4 + #886, #3967
  static MapaFase4 + #887, #3967
  static MapaFase4 + #888, #3967
  static MapaFase4 + #889, #3967
  static MapaFase4 + #890, #3967
  static MapaFase4 + #891, #3967
  static MapaFase4 + #892, #3967
  static MapaFase4 + #893, #3967
  static MapaFase4 + #894, #3967
  static MapaFase4 + #895, #3967
  static MapaFase4 + #896, #3967
  static MapaFase4 + #897, #3967
  static MapaFase4 + #898, #3967
  static MapaFase4 + #899, #3967
  static MapaFase4 + #900, #3967
  static MapaFase4 + #901, #3967
  static MapaFase4 + #902, #3967
  static MapaFase4 + #903, #3876
  static MapaFase4 + #904, #3876
  static MapaFase4 + #905, #2060
  static MapaFase4 + #906, #2084
  static MapaFase4 + #907, #1828
  static MapaFase4 + #908, #1828
  static MapaFase4 + #909, #2084
  static MapaFase4 + #910, #2084
  static MapaFase4 + #911, #2084
  static MapaFase4 + #912, #1828
  static MapaFase4 + #913, #1828
  static MapaFase4 + #914, #1828
  static MapaFase4 + #915, #2084
  static MapaFase4 + #916, #2084
  static MapaFase4 + #917, #2084
  static MapaFase4 + #918, #1828
  static MapaFase4 + #919, #1828

  ;Linha 23
  static MapaFase4 + #920, #3967
  static MapaFase4 + #921, #3967
  static MapaFase4 + #922, #3967
  static MapaFase4 + #923, #3967
  static MapaFase4 + #924, #3967
  static MapaFase4 + #925, #3967
  static MapaFase4 + #926, #3967
  static MapaFase4 + #927, #3967
  static MapaFase4 + #928, #3967
  static MapaFase4 + #929, #3967
  static MapaFase4 + #930, #3967
  static MapaFase4 + #931, #3967
  static MapaFase4 + #932, #3967
  static MapaFase4 + #933, #3967
  static MapaFase4 + #934, #3967
  static MapaFase4 + #935, #3967
  static MapaFase4 + #936, #3967
  static MapaFase4 + #937, #3967
  static MapaFase4 + #938, #3967
  static MapaFase4 + #939, #3967
  static MapaFase4 + #940, #3967
  static MapaFase4 + #941, #3967
  static MapaFase4 + #942, #3967
  static MapaFase4 + #943, #3876
  static MapaFase4 + #944, #3876
  static MapaFase4 + #945, #1803
  static MapaFase4 + #946, #1828
  static MapaFase4 + #947, #1828
  static MapaFase4 + #948, #1828
  static MapaFase4 + #949, #2084
  static MapaFase4 + #950, #2084
  static MapaFase4 + #951, #2084
  static MapaFase4 + #952, #1828
  static MapaFase4 + #953, #1828
  static MapaFase4 + #954, #1828
  static MapaFase4 + #955, #2084
  static MapaFase4 + #956, #2084
  static MapaFase4 + #957, #2084
  static MapaFase4 + #958, #1828
  static MapaFase4 + #959, #1828

  ;Linha 24
  static MapaFase4 + #960, #1067
  static MapaFase4 + #961, #3967
  static MapaFase4 + #962, #3967
  static MapaFase4 + #963, #3967
  static MapaFase4 + #964, #3967
  static MapaFase4 + #965, #3967
  static MapaFase4 + #966, #3967
  static MapaFase4 + #967, #3967
  static MapaFase4 + #968, #3967
  static MapaFase4 + #969, #3967
  static MapaFase4 + #970, #3967
  static MapaFase4 + #971, #3967
  static MapaFase4 + #972, #3967
  static MapaFase4 + #973, #3967
  static MapaFase4 + #974, #3967
  static MapaFase4 + #975, #3967
  static MapaFase4 + #976, #3967
  static MapaFase4 + #977, #3967
  static MapaFase4 + #978, #3967
  static MapaFase4 + #979, #3967
  static MapaFase4 + #980, #3967
  static MapaFase4 + #981, #3967
  static MapaFase4 + #982, #3967
  static MapaFase4 + #983, #3967
  static MapaFase4 + #984, #3876
  static MapaFase4 + #985, #3876
  static MapaFase4 + #986, #1804
  static MapaFase4 + #987, #1828
  static MapaFase4 + #988, #1828
  static MapaFase4 + #989, #2084
  static MapaFase4 + #990, #2084
  static MapaFase4 + #991, #2084
  static MapaFase4 + #992, #1828
  static MapaFase4 + #993, #1828
  static MapaFase4 + #994, #1828
  static MapaFase4 + #995, #1828
  static MapaFase4 + #996, #1828
  static MapaFase4 + #997, #1828
  static MapaFase4 + #998, #1828
  static MapaFase4 + #999, #1828

  ;Linha 25
  static MapaFase4 + #1000, #3967
  static MapaFase4 + #1001, #3967
  static MapaFase4 + #1002, #3967
  static MapaFase4 + #1003, #3967
  static MapaFase4 + #1004, #3967
  static MapaFase4 + #1005, #3967
  static MapaFase4 + #1006, #3967
  static MapaFase4 + #1007, #3967
  static MapaFase4 + #1008, #3967
  static MapaFase4 + #1009, #3967
  static MapaFase4 + #1010, #3967
  static MapaFase4 + #1011, #3967
  static MapaFase4 + #1012, #3967
  static MapaFase4 + #1013, #3967
  static MapaFase4 + #1014, #3967
  static MapaFase4 + #1015, #3967
  static MapaFase4 + #1016, #3967
  static MapaFase4 + #1017, #3967
  static MapaFase4 + #1018, #3967
  static MapaFase4 + #1019, #3967
  static MapaFase4 + #1020, #3967
  static MapaFase4 + #1021, #3967
  static MapaFase4 + #1022, #3967
  static MapaFase4 + #1023, #3967
  static MapaFase4 + #1024, #3876
  static MapaFase4 + #1025, #3876
  static MapaFase4 + #1026, #1803
  static MapaFase4 + #1027, #1828
  static MapaFase4 + #1028, #1828
  static MapaFase4 + #1029, #1828
  static MapaFase4 + #1030, #1828
  static MapaFase4 + #1031, #1828
  static MapaFase4 + #1032, #1828
  static MapaFase4 + #1033, #1828
  static MapaFase4 + #1034, #1828
  static MapaFase4 + #1035, #2084
  static MapaFase4 + #1036, #2084
  static MapaFase4 + #1037, #2084
  static MapaFase4 + #1038, #1828
  static MapaFase4 + #1039, #1828

  ;Linha 26
  static MapaFase4 + #1040, #3967
  static MapaFase4 + #1041, #3967
  static MapaFase4 + #1042, #3967
  static MapaFase4 + #1043, #3967
  static MapaFase4 + #1044, #3967
  static MapaFase4 + #1045, #3967
  static MapaFase4 + #1046, #3967
  static MapaFase4 + #1047, #3967
  static MapaFase4 + #1048, #3967
  static MapaFase4 + #1049, #3967
  static MapaFase4 + #1050, #3967
  static MapaFase4 + #1051, #3967
  static MapaFase4 + #1052, #3967
  static MapaFase4 + #1053, #3967
  static MapaFase4 + #1054, #3967
  static MapaFase4 + #1055, #3967
  static MapaFase4 + #1056, #3967
  static MapaFase4 + #1057, #3967
  static MapaFase4 + #1058, #3967
  static MapaFase4 + #1059, #3967
  static MapaFase4 + #1060, #3967
  static MapaFase4 + #1061, #3967
  static MapaFase4 + #1062, #3967
  static MapaFase4 + #1063, #3967
  static MapaFase4 + #1064, #3967
  static MapaFase4 + #1065, #3876
  static MapaFase4 + #1066, #3876
  static MapaFase4 + #1067, #1823
  static MapaFase4 + #1068, #1828
  static MapaFase4 + #1069, #2084
  static MapaFase4 + #1070, #2084
  static MapaFase4 + #1071, #2084
  static MapaFase4 + #1072, #1828
  static MapaFase4 + #1073, #1828
  static MapaFase4 + #1074, #1828
  static MapaFase4 + #1075, #2084
  static MapaFase4 + #1076, #2084
  static MapaFase4 + #1077, #2084
  static MapaFase4 + #1078, #1828
  static MapaFase4 + #1079, #1828

  ;Linha 27
  static MapaFase4 + #1080, #3967
  static MapaFase4 + #1081, #3967
  static MapaFase4 + #1082, #3967
  static MapaFase4 + #1083, #3967
  static MapaFase4 + #1084, #3967
  static MapaFase4 + #1085, #3967
  static MapaFase4 + #1086, #3967
  static MapaFase4 + #1087, #3967
  static MapaFase4 + #1088, #3967
  static MapaFase4 + #1089, #3967
  static MapaFase4 + #1090, #3967
  static MapaFase4 + #1091, #3967
  static MapaFase4 + #1092, #3967
  static MapaFase4 + #1093, #3967
  static MapaFase4 + #1094, #3967
  static MapaFase4 + #1095, #3967
  static MapaFase4 + #1096, #3967
  static MapaFase4 + #1097, #3967
  static MapaFase4 + #1098, #3967
  static MapaFase4 + #1099, #3967
  static MapaFase4 + #1100, #3967
  static MapaFase4 + #1101, #3967
  static MapaFase4 + #1102, #3967
  static MapaFase4 + #1103, #3967
  static MapaFase4 + #1104, #3967
  static MapaFase4 + #1105, #3967
  static MapaFase4 + #1106, #3876
  static MapaFase4 + #1107, #3967
  static MapaFase4 + #1108, #1823
  static MapaFase4 + #1109, #2084
  static MapaFase4 + #1110, #2084
  static MapaFase4 + #1111, #2084
  static MapaFase4 + #1112, #1828
  static MapaFase4 + #1113, #1828
  static MapaFase4 + #1114, #1828
  static MapaFase4 + #1115, #2084
  static MapaFase4 + #1116, #2084
  static MapaFase4 + #1117, #2084
  static MapaFase4 + #1118, #1828
  static MapaFase4 + #1119, #1828

  ;Linha 28
  static MapaFase4 + #1120, #3967
  static MapaFase4 + #1121, #3967
  static MapaFase4 + #1122, #3967
  static MapaFase4 + #1123, #3967
  static MapaFase4 + #1124, #3967
  static MapaFase4 + #1125, #3967
  static MapaFase4 + #1126, #3967
  static MapaFase4 + #1127, #3967
  static MapaFase4 + #1128, #3967
  static MapaFase4 + #1129, #3967
  static MapaFase4 + #1130, #3967
  static MapaFase4 + #1131, #3967
  static MapaFase4 + #1132, #3967
  static MapaFase4 + #1133, #3967
  static MapaFase4 + #1134, #3967
  static MapaFase4 + #1135, #3967
  static MapaFase4 + #1136, #3967
  static MapaFase4 + #1137, #3967
  static MapaFase4 + #1138, #3967
  static MapaFase4 + #1139, #3967
  static MapaFase4 + #1140, #3967
  static MapaFase4 + #1141, #3967
  static MapaFase4 + #1142, #3967
  static MapaFase4 + #1143, #3967
  static MapaFase4 + #1144, #3967
  static MapaFase4 + #1145, #3967
  static MapaFase4 + #1146, #3967
  static MapaFase4 + #1147, #3876
  static MapaFase4 + #1148, #3967
  static MapaFase4 + #1149, #2079
  static MapaFase4 + #1150, #2084
  static MapaFase4 + #1151, #2084
  static MapaFase4 + #1152, #1828
  static MapaFase4 + #1153, #1828
  static MapaFase4 + #1154, #1828
  static MapaFase4 + #1155, #1828
  static MapaFase4 + #1156, #1828
  static MapaFase4 + #1157, #1828
  static MapaFase4 + #1158, #1828
  static MapaFase4 + #1159, #1828

  ;Linha 29
  static MapaFase4 + #1160, #3967
  static MapaFase4 + #1161, #3967
  static MapaFase4 + #1162, #3967
  static MapaFase4 + #1163, #3967
  static MapaFase4 + #1164, #3967
  static MapaFase4 + #1165, #3967
  static MapaFase4 + #1166, #3967
  static MapaFase4 + #1167, #3967
  static MapaFase4 + #1168, #3967
  static MapaFase4 + #1169, #3967
  static MapaFase4 + #1170, #3967
  static MapaFase4 + #1171, #3967
  static MapaFase4 + #1172, #3967
  static MapaFase4 + #1173, #3967
  static MapaFase4 + #1174, #3967
  static MapaFase4 + #1175, #3967
  static MapaFase4 + #1176, #3967
  static MapaFase4 + #1177, #3967
  static MapaFase4 + #1178, #3967
  static MapaFase4 + #1179, #3967
  static MapaFase4 + #1180, #3967
  static MapaFase4 + #1181, #3967
  static MapaFase4 + #1182, #3967
  static MapaFase4 + #1183, #3967
  static MapaFase4 + #1184, #3967
  static MapaFase4 + #1185, #3967
  static MapaFase4 + #1186, #3967
  static MapaFase4 + #1187, #3967
  static MapaFase4 + #1188, #3876
  static MapaFase4 + #1189, #3967
  static MapaFase4 + #1190, #2058
  static MapaFase4 + #1191, #2057
  static MapaFase4 + #1192, #1828
  static MapaFase4 + #1193, #1828
  static MapaFase4 + #1194, #1828
  static MapaFase4 + #1195, #2084
  static MapaFase4 + #1196, #2084
  static MapaFase4 + #1197, #2084
  static MapaFase4 + #1198, #1828
  static MapaFase4 + #1199, #1828
  
  
  MapaFase5 : var #1200
  ;Linha 0
  static MapaFase5 + #0, #2080
  static MapaFase5 + #1, #2080
  static MapaFase5 + #2, #2080
  static MapaFase5 + #3, #2080
  static MapaFase5 + #4, #2080
  static MapaFase5 + #5, #2080
  static MapaFase5 + #6, #2080
  static MapaFase5 + #7, #2080
  static MapaFase5 + #8, #2080
  static MapaFase5 + #9, #2080
  static MapaFase5 + #10, #2080
  static MapaFase5 + #11, #2080
  static MapaFase5 + #12, #2080
  static MapaFase5 + #13, #2080
  static MapaFase5 + #14, #2080
  static MapaFase5 + #15, #2080
  static MapaFase5 + #16, #2080
  static MapaFase5 + #17, #2080
  static MapaFase5 + #18, #2080
  static MapaFase5 + #19, #2080
  static MapaFase5 + #20, #3967
  static MapaFase5 + #21, #3967
  static MapaFase5 + #22, #3967
  static MapaFase5 + #23, #3967
  static MapaFase5 + #24, #1824
  static MapaFase5 + #25, #1824
  static MapaFase5 + #26, #32
  static MapaFase5 + #27, #32
  static MapaFase5 + #28, #2080
  static MapaFase5 + #29, #2080
  static MapaFase5 + #30, #2080
  static MapaFase5 + #31, #2080
  static MapaFase5 + #32, #2080
  static MapaFase5 + #33, #2080
  static MapaFase5 + #34, #2080
  static MapaFase5 + #35, #2080
  static MapaFase5 + #36, #2080
  static MapaFase5 + #37, #2080
  static MapaFase5 + #38, #2080
  static MapaFase5 + #39, #2080

  ;Linha 1
  static MapaFase5 + #40, #2080
  static MapaFase5 + #41, #2080
  static MapaFase5 + #42, #2080
  static MapaFase5 + #43, #2080
  static MapaFase5 + #44, #2080
  static MapaFase5 + #45, #2080
  static MapaFase5 + #46, #2080
  static MapaFase5 + #47, #2080
  static MapaFase5 + #48, #2080
  static MapaFase5 + #49, #2080
  static MapaFase5 + #50, #2080
  static MapaFase5 + #51, #2080
  static MapaFase5 + #52, #2080
  static MapaFase5 + #53, #2080
  static MapaFase5 + #54, #2080
  static MapaFase5 + #55, #2080
  static MapaFase5 + #56, #2080
  static MapaFase5 + #57, #2080
  static MapaFase5 + #58, #2080
  static MapaFase5 + #59, #2080
  static MapaFase5 + #60, #2080
  static MapaFase5 + #61, #2080
  static MapaFase5 + #62, #2080
  static MapaFase5 + #63, #2080
  static MapaFase5 + #64, #2080
  static MapaFase5 + #65, #2080
  static MapaFase5 + #66, #2080
  static MapaFase5 + #67, #2080
  static MapaFase5 + #68, #2080
  static MapaFase5 + #69, #2080
  static MapaFase5 + #70, #2080
  static MapaFase5 + #71, #2080
  static MapaFase5 + #72, #2080
  static MapaFase5 + #73, #2080
  static MapaFase5 + #74, #2080
  static MapaFase5 + #75, #2080
  static MapaFase5 + #76, #2080
  static MapaFase5 + #77, #2080
  static MapaFase5 + #78, #2080
  static MapaFase5 + #79, #2080

  ;Linha 2
  static MapaFase5 + #80, #2080
  static MapaFase5 + #81, #2080
  static MapaFase5 + #82, #2080
  static MapaFase5 + #83, #2080
  static MapaFase5 + #84, #2080
  static MapaFase5 + #85, #2080
  static MapaFase5 + #86, #2080
  static MapaFase5 + #87, #2080
  static MapaFase5 + #88, #2080
  static MapaFase5 + #89, #2080
  static MapaFase5 + #90, #2080
  static MapaFase5 + #91, #2080
  static MapaFase5 + #92, #3967
  static MapaFase5 + #93, #3967
  static MapaFase5 + #94, #3967
  static MapaFase5 + #95, #3967
  static MapaFase5 + #96, #2080
  static MapaFase5 + #97, #2080
  static MapaFase5 + #98, #2080
  static MapaFase5 + #99, #2080
  static MapaFase5 + #100, #2080
  static MapaFase5 + #101, #2080
  static MapaFase5 + #102, #2080
  static MapaFase5 + #103, #2080
  static MapaFase5 + #104, #2080
  static MapaFase5 + #105, #2080
  static MapaFase5 + #106, #2080
  static MapaFase5 + #107, #2080
  static MapaFase5 + #108, #2080
  static MapaFase5 + #109, #2080
  static MapaFase5 + #110, #2080
  static MapaFase5 + #111, #2080
  static MapaFase5 + #112, #2080
  static MapaFase5 + #113, #2080
  static MapaFase5 + #114, #2080
  static MapaFase5 + #115, #2080
  static MapaFase5 + #116, #2080
  static MapaFase5 + #117, #2080
  static MapaFase5 + #118, #2080
  static MapaFase5 + #119, #2080

  ;Linha 3
  static MapaFase5 + #120, #2119
  static MapaFase5 + #121, #2125
  static MapaFase5 + #122, #2117
  static MapaFase5 + #123, #2125
  static MapaFase5 + #124, #2117
  static MapaFase5 + #125, #2125
  static MapaFase5 + #126, #2117
  static MapaFase5 + #127, #2125
  static MapaFase5 + #128, #2117
  static MapaFase5 + #129, #2115
  static MapaFase5 + #130, #2089
  static MapaFase5 + #131, #2091
  static MapaFase5 + #132, #3967
  static MapaFase5 + #133, #3967
  static MapaFase5 + #134, #3967
  static MapaFase5 + #135, #3967
  static MapaFase5 + #136, #3967
  static MapaFase5 + #137, #3967
  static MapaFase5 + #138, #3967
  static MapaFase5 + #139, #3967
  static MapaFase5 + #140, #3967
  static MapaFase5 + #141, #3967
  static MapaFase5 + #142, #3967
  static MapaFase5 + #143, #3967
  static MapaFase5 + #144, #3967
  static MapaFase5 + #145, #1824
  static MapaFase5 + #146, #32
  static MapaFase5 + #147, #32
  static MapaFase5 + #148, #32
  static MapaFase5 + #149, #2127
  static MapaFase5 + #150, #2115
  static MapaFase5 + #151, #2119
  static MapaFase5 + #152, #2117
  static MapaFase5 + #153, #2117
  static MapaFase5 + #154, #2117
  static MapaFase5 + #155, #2117
  static MapaFase5 + #156, #2117
  static MapaFase5 + #157, #2117
  static MapaFase5 + #158, #2117
  static MapaFase5 + #159, #2115

  ;Linha 4
  static MapaFase5 + #160, #2119
  static MapaFase5 + #161, #2125
  static MapaFase5 + #162, #2117
  static MapaFase5 + #163, #2125
  static MapaFase5 + #164, #2117
  static MapaFase5 + #165, #2125
  static MapaFase5 + #166, #2117
  static MapaFase5 + #167, #2125
  static MapaFase5 + #168, #2117
  static MapaFase5 + #169, #2115
  static MapaFase5 + #170, #2119
  static MapaFase5 + #171, #2127
  static MapaFase5 + #172, #3967
  static MapaFase5 + #173, #3967
  static MapaFase5 + #174, #3967
  static MapaFase5 + #175, #3967
  static MapaFase5 + #176, #3967
  static MapaFase5 + #177, #3967
  static MapaFase5 + #178, #3967
  static MapaFase5 + #179, #3967
  static MapaFase5 + #180, #3967
  static MapaFase5 + #181, #32
  static MapaFase5 + #182, #32
  static MapaFase5 + #183, #32
  static MapaFase5 + #184, #32
  static MapaFase5 + #185, #32
  static MapaFase5 + #186, #32
  static MapaFase5 + #187, #32
  static MapaFase5 + #188, #32
  static MapaFase5 + #189, #2091
  static MapaFase5 + #190, #2095
  static MapaFase5 + #191, #2119
  static MapaFase5 + #192, #2125
  static MapaFase5 + #193, #2125
  static MapaFase5 + #194, #2125
  static MapaFase5 + #195, #2125
  static MapaFase5 + #196, #2125
  static MapaFase5 + #197, #2125
  static MapaFase5 + #198, #2125
  static MapaFase5 + #199, #2115

  ;Linha 5
  static MapaFase5 + #200, #2119
  static MapaFase5 + #201, #2125
  static MapaFase5 + #202, #2117
  static MapaFase5 + #203, #2125
  static MapaFase5 + #204, #2117
  static MapaFase5 + #205, #2125
  static MapaFase5 + #206, #2117
  static MapaFase5 + #207, #2125
  static MapaFase5 + #208, #2117
  static MapaFase5 + #209, #2115
  static MapaFase5 + #210, #2089
  static MapaFase5 + #211, #2090
  static MapaFase5 + #212, #3967
  static MapaFase5 + #213, #3967
  static MapaFase5 + #214, #3967
  static MapaFase5 + #215, #3967
  static MapaFase5 + #216, #3967
  static MapaFase5 + #217, #3967
  static MapaFase5 + #218, #3967
  static MapaFase5 + #219, #3967
  static MapaFase5 + #220, #3967
  static MapaFase5 + #221, #32
  static MapaFase5 + #222, #32
  static MapaFase5 + #223, #32
  static MapaFase5 + #224, #32
  static MapaFase5 + #225, #32
  static MapaFase5 + #226, #32
  static MapaFase5 + #227, #32
  static MapaFase5 + #228, #32
  static MapaFase5 + #229, #2127
  static MapaFase5 + #230, #2115
  static MapaFase5 + #231, #2119
  static MapaFase5 + #232, #2117
  static MapaFase5 + #233, #2117
  static MapaFase5 + #234, #2117
  static MapaFase5 + #235, #2117
  static MapaFase5 + #236, #2117
  static MapaFase5 + #237, #2117
  static MapaFase5 + #238, #2117
  static MapaFase5 + #239, #2115

  ;Linha 6
  static MapaFase5 + #240, #2119
  static MapaFase5 + #241, #2125
  static MapaFase5 + #242, #2117
  static MapaFase5 + #243, #2125
  static MapaFase5 + #244, #2117
  static MapaFase5 + #245, #2125
  static MapaFase5 + #246, #2117
  static MapaFase5 + #247, #2125
  static MapaFase5 + #248, #2117
  static MapaFase5 + #249, #2115
  static MapaFase5 + #250, #2119
  static MapaFase5 + #251, #2127
  static MapaFase5 + #252, #3967
  static MapaFase5 + #253, #3967
  static MapaFase5 + #254, #32
  static MapaFase5 + #255, #3967
  static MapaFase5 + #256, #3967
  static MapaFase5 + #257, #3967
  static MapaFase5 + #258, #32
  static MapaFase5 + #259, #3967
  static MapaFase5 + #260, #3967
  static MapaFase5 + #261, #3967
  static MapaFase5 + #262, #32
  static MapaFase5 + #263, #32
  static MapaFase5 + #264, #32
  static MapaFase5 + #265, #32
  static MapaFase5 + #266, #32
  static MapaFase5 + #267, #32
  static MapaFase5 + #268, #32
  static MapaFase5 + #269, #2090
  static MapaFase5 + #270, #2095
  static MapaFase5 + #271, #2119
  static MapaFase5 + #272, #2125
  static MapaFase5 + #273, #2125
  static MapaFase5 + #274, #2125
  static MapaFase5 + #275, #2125
  static MapaFase5 + #276, #2125
  static MapaFase5 + #277, #2125
  static MapaFase5 + #278, #2125
  static MapaFase5 + #279, #2115

  ;Linha 7
  static MapaFase5 + #280, #2119
  static MapaFase5 + #281, #2125
  static MapaFase5 + #282, #2117
  static MapaFase5 + #283, #2125
  static MapaFase5 + #284, #2117
  static MapaFase5 + #285, #2125
  static MapaFase5 + #286, #2117
  static MapaFase5 + #287, #2125
  static MapaFase5 + #288, #2117
  static MapaFase5 + #289, #2115
  static MapaFase5 + #290, #2089
  static MapaFase5 + #291, #2091
  static MapaFase5 + #292, #3967
  static MapaFase5 + #293, #3967
  static MapaFase5 + #294, #3967
  static MapaFase5 + #295, #3967
  static MapaFase5 + #296, #3967
  static MapaFase5 + #297, #3967
  static MapaFase5 + #298, #3967
  static MapaFase5 + #299, #3967
  static MapaFase5 + #300, #3967
  static MapaFase5 + #301, #3967
  static MapaFase5 + #302, #32
  static MapaFase5 + #303, #32
  static MapaFase5 + #304, #32
  static MapaFase5 + #305, #32
  static MapaFase5 + #306, #32
  static MapaFase5 + #307, #32
  static MapaFase5 + #308, #32
  static MapaFase5 + #309, #2127
  static MapaFase5 + #310, #2115
  static MapaFase5 + #311, #2119
  static MapaFase5 + #312, #2117
  static MapaFase5 + #313, #2117
  static MapaFase5 + #314, #2117
  static MapaFase5 + #315, #2117
  static MapaFase5 + #316, #2117
  static MapaFase5 + #317, #2117
  static MapaFase5 + #318, #2117
  static MapaFase5 + #319, #2115

  ;Linha 8
  static MapaFase5 + #320, #2119
  static MapaFase5 + #321, #2125
  static MapaFase5 + #322, #2117
  static MapaFase5 + #323, #2125
  static MapaFase5 + #324, #2117
  static MapaFase5 + #325, #2125
  static MapaFase5 + #326, #2117
  static MapaFase5 + #327, #2125
  static MapaFase5 + #328, #2117
  static MapaFase5 + #329, #2115
  static MapaFase5 + #330, #2119
  static MapaFase5 + #331, #2127
  static MapaFase5 + #332, #3967
  static MapaFase5 + #333, #3967
  static MapaFase5 + #334, #3967
  static MapaFase5 + #335, #3967
  static MapaFase5 + #336, #3967
  static MapaFase5 + #337, #3967
  static MapaFase5 + #338, #3967
  static MapaFase5 + #339, #3967
  static MapaFase5 + #340, #3967
  static MapaFase5 + #341, #3967
  static MapaFase5 + #342, #3967
  static MapaFase5 + #343, #32
  static MapaFase5 + #344, #32
  static MapaFase5 + #345, #32
  static MapaFase5 + #346, #32
  static MapaFase5 + #347, #32
  static MapaFase5 + #348, #32
  static MapaFase5 + #349, #2091
  static MapaFase5 + #350, #2095
  static MapaFase5 + #351, #2119
  static MapaFase5 + #352, #2125
  static MapaFase5 + #353, #2125
  static MapaFase5 + #354, #2125
  static MapaFase5 + #355, #2125
  static MapaFase5 + #356, #2125
  static MapaFase5 + #357, #2125
  static MapaFase5 + #358, #2125
  static MapaFase5 + #359, #2115

  ;Linha 9
  static MapaFase5 + #360, #2119
  static MapaFase5 + #361, #2125
  static MapaFase5 + #362, #2117
  static MapaFase5 + #363, #2125
  static MapaFase5 + #364, #2117
  static MapaFase5 + #365, #2125
  static MapaFase5 + #366, #2117
  static MapaFase5 + #367, #2125
  static MapaFase5 + #368, #2117
  static MapaFase5 + #369, #2115
  static MapaFase5 + #370, #2089
  static MapaFase5 + #371, #2090
  static MapaFase5 + #372, #32
  static MapaFase5 + #373, #3967
  static MapaFase5 + #374, #3967
  static MapaFase5 + #375, #3967
  static MapaFase5 + #376, #3967
  static MapaFase5 + #377, #3967
  static MapaFase5 + #378, #3967
  static MapaFase5 + #379, #3967
  static MapaFase5 + #380, #3967
  static MapaFase5 + #381, #3967
  static MapaFase5 + #382, #3967
  static MapaFase5 + #383, #32
  static MapaFase5 + #384, #32
  static MapaFase5 + #385, #32
  static MapaFase5 + #386, #32
  static MapaFase5 + #387, #32
  static MapaFase5 + #388, #32
  static MapaFase5 + #389, #2127
  static MapaFase5 + #390, #2115
  static MapaFase5 + #391, #2119
  static MapaFase5 + #392, #2117
  static MapaFase5 + #393, #2117
  static MapaFase5 + #394, #2117
  static MapaFase5 + #395, #2117
  static MapaFase5 + #396, #2117
  static MapaFase5 + #397, #2117
  static MapaFase5 + #398, #2117
  static MapaFase5 + #399, #2115

  ;Linha 10
  static MapaFase5 + #400, #2119
  static MapaFase5 + #401, #2125
  static MapaFase5 + #402, #2117
  static MapaFase5 + #403, #2125
  static MapaFase5 + #404, #2117
  static MapaFase5 + #405, #2125
  static MapaFase5 + #406, #2117
  static MapaFase5 + #407, #2125
  static MapaFase5 + #408, #2117
  static MapaFase5 + #409, #2115
  static MapaFase5 + #410, #2119
  static MapaFase5 + #411, #2127
  static MapaFase5 + #412, #32
  static MapaFase5 + #413, #32
  static MapaFase5 + #414, #3967
  static MapaFase5 + #415, #3967
  static MapaFase5 + #416, #3967
  static MapaFase5 + #417, #3967
  static MapaFase5 + #418, #3967
  static MapaFase5 + #419, #3967
  static MapaFase5 + #420, #3967
  static MapaFase5 + #421, #3967
  static MapaFase5 + #422, #32
  static MapaFase5 + #423, #32
  static MapaFase5 + #424, #32
  static MapaFase5 + #425, #32
  static MapaFase5 + #426, #32
  static MapaFase5 + #427, #32
  static MapaFase5 + #428, #32
  static MapaFase5 + #429, #2090
  static MapaFase5 + #430, #2095
  static MapaFase5 + #431, #2119
  static MapaFase5 + #432, #2125
  static MapaFase5 + #433, #2125
  static MapaFase5 + #434, #2125
  static MapaFase5 + #435, #2125
  static MapaFase5 + #436, #2125
  static MapaFase5 + #437, #2125
  static MapaFase5 + #438, #2125
  static MapaFase5 + #439, #2115

  ;Linha 11
  static MapaFase5 + #440, #2119
  static MapaFase5 + #441, #2125
  static MapaFase5 + #442, #2117
  static MapaFase5 + #443, #2125
  static MapaFase5 + #444, #2117
  static MapaFase5 + #445, #2125
  static MapaFase5 + #446, #2117
  static MapaFase5 + #447, #2125
  static MapaFase5 + #448, #2117
  static MapaFase5 + #449, #2115
  static MapaFase5 + #450, #2089
  static MapaFase5 + #451, #2091
  static MapaFase5 + #452, #3967
  static MapaFase5 + #453, #3967
  static MapaFase5 + #454, #32
  static MapaFase5 + #455, #3967
  static MapaFase5 + #456, #3967
  static MapaFase5 + #457, #3967
  static MapaFase5 + #458, #3967
  static MapaFase5 + #459, #3967
  static MapaFase5 + #460, #3967
  static MapaFase5 + #461, #32
  static MapaFase5 + #462, #32
  static MapaFase5 + #463, #32
  static MapaFase5 + #464, #32
  static MapaFase5 + #465, #32
  static MapaFase5 + #466, #32
  static MapaFase5 + #467, #32
  static MapaFase5 + #468, #32
  static MapaFase5 + #469, #2127
  static MapaFase5 + #470, #2115
  static MapaFase5 + #471, #2119
  static MapaFase5 + #472, #2117
  static MapaFase5 + #473, #2117
  static MapaFase5 + #474, #2117
  static MapaFase5 + #475, #2117
  static MapaFase5 + #476, #2117
  static MapaFase5 + #477, #2117
  static MapaFase5 + #478, #2117
  static MapaFase5 + #479, #2115

  ;Linha 12
  static MapaFase5 + #480, #2119
  static MapaFase5 + #481, #2125
  static MapaFase5 + #482, #2117
  static MapaFase5 + #483, #2125
  static MapaFase5 + #484, #2117
  static MapaFase5 + #485, #2125
  static MapaFase5 + #486, #2117
  static MapaFase5 + #487, #2125
  static MapaFase5 + #488, #2117
  static MapaFase5 + #489, #2115
  static MapaFase5 + #490, #2119
  static MapaFase5 + #491, #2127
  static MapaFase5 + #492, #3967
  static MapaFase5 + #493, #3967
  static MapaFase5 + #494, #3967
  static MapaFase5 + #495, #3967
  static MapaFase5 + #496, #32
  static MapaFase5 + #497, #3967
  static MapaFase5 + #498, #3967
  static MapaFase5 + #499, #3967
  static MapaFase5 + #500, #3967
  static MapaFase5 + #501, #32
  static MapaFase5 + #502, #32
  static MapaFase5 + #503, #32
  static MapaFase5 + #504, #32
  static MapaFase5 + #505, #32
  static MapaFase5 + #506, #32
  static MapaFase5 + #507, #32
  static MapaFase5 + #508, #32
  static MapaFase5 + #509, #2091
  static MapaFase5 + #510, #2095
  static MapaFase5 + #511, #2119
  static MapaFase5 + #512, #2125
  static MapaFase5 + #513, #2125
  static MapaFase5 + #514, #2125
  static MapaFase5 + #515, #2125
  static MapaFase5 + #516, #2125
  static MapaFase5 + #517, #2125
  static MapaFase5 + #518, #2125
  static MapaFase5 + #519, #2115

  ;Linha 13
  static MapaFase5 + #520, #2119
  static MapaFase5 + #521, #2125
  static MapaFase5 + #522, #2117
  static MapaFase5 + #523, #2125
  static MapaFase5 + #524, #2117
  static MapaFase5 + #525, #2125
  static MapaFase5 + #526, #2117
  static MapaFase5 + #527, #2125
  static MapaFase5 + #528, #2117
  static MapaFase5 + #529, #2115
  static MapaFase5 + #530, #2089
  static MapaFase5 + #531, #2090
  static MapaFase5 + #532, #32
  static MapaFase5 + #533, #3967
  static MapaFase5 + #534, #3967
  static MapaFase5 + #535, #3967
  static MapaFase5 + #536, #3967
  static MapaFase5 + #537, #32
  static MapaFase5 + #538, #3967
  static MapaFase5 + #539, #3967
  static MapaFase5 + #540, #3967
  static MapaFase5 + #541, #3967
  static MapaFase5 + #542, #32
  static MapaFase5 + #543, #32
  static MapaFase5 + #544, #32
  static MapaFase5 + #545, #32
  static MapaFase5 + #546, #32
  static MapaFase5 + #547, #32
  static MapaFase5 + #548, #32
  static MapaFase5 + #549, #2127
  static MapaFase5 + #550, #2115
  static MapaFase5 + #551, #2119
  static MapaFase5 + #552, #2117
  static MapaFase5 + #553, #2117
  static MapaFase5 + #554, #2117
  static MapaFase5 + #555, #2117
  static MapaFase5 + #556, #2117
  static MapaFase5 + #557, #2117
  static MapaFase5 + #558, #2117
  static MapaFase5 + #559, #2115

  ;Linha 14
  static MapaFase5 + #560, #2119
  static MapaFase5 + #561, #2125
  static MapaFase5 + #562, #2117
  static MapaFase5 + #563, #2125
  static MapaFase5 + #564, #2117
  static MapaFase5 + #565, #2125
  static MapaFase5 + #566, #2117
  static MapaFase5 + #567, #2125
  static MapaFase5 + #568, #2117
  static MapaFase5 + #569, #2115
  static MapaFase5 + #570, #2119
  static MapaFase5 + #571, #2127
  static MapaFase5 + #572, #32
  static MapaFase5 + #573, #32
  static MapaFase5 + #574, #3967
  static MapaFase5 + #575, #3967
  static MapaFase5 + #576, #3967
  static MapaFase5 + #577, #3967
  static MapaFase5 + #578, #3967
  static MapaFase5 + #579, #32
  static MapaFase5 + #580, #3967
  static MapaFase5 + #581, #32
  static MapaFase5 + #582, #32
  static MapaFase5 + #583, #32
  static MapaFase5 + #584, #32
  static MapaFase5 + #585, #32
  static MapaFase5 + #586, #32
  static MapaFase5 + #587, #32
  static MapaFase5 + #588, #32
  static MapaFase5 + #589, #2090
  static MapaFase5 + #590, #2095
  static MapaFase5 + #591, #2119
  static MapaFase5 + #592, #2125
  static MapaFase5 + #593, #2125
  static MapaFase5 + #594, #2125
  static MapaFase5 + #595, #2125
  static MapaFase5 + #596, #2125
  static MapaFase5 + #597, #2125
  static MapaFase5 + #598, #2125
  static MapaFase5 + #599, #2115

  ;Linha 15
  static MapaFase5 + #600, #2119
  static MapaFase5 + #601, #2125
  static MapaFase5 + #602, #2117
  static MapaFase5 + #603, #2125
  static MapaFase5 + #604, #2117
  static MapaFase5 + #605, #2125
  static MapaFase5 + #606, #2117
  static MapaFase5 + #607, #2125
  static MapaFase5 + #608, #2117
  static MapaFase5 + #609, #2115
  static MapaFase5 + #610, #2089
  static MapaFase5 + #611, #2091
  static MapaFase5 + #612, #3967
  static MapaFase5 + #613, #3967
  static MapaFase5 + #614, #3967
  static MapaFase5 + #615, #3967
  static MapaFase5 + #616, #3967
  static MapaFase5 + #617, #3967
  static MapaFase5 + #618, #3967
  static MapaFase5 + #619, #3967
  static MapaFase5 + #620, #32
  static MapaFase5 + #621, #32
  static MapaFase5 + #622, #32
  static MapaFase5 + #623, #32
  static MapaFase5 + #624, #32
  static MapaFase5 + #625, #32
  static MapaFase5 + #626, #32
  static MapaFase5 + #627, #32
  static MapaFase5 + #628, #32
  static MapaFase5 + #629, #2127
  static MapaFase5 + #630, #2115
  static MapaFase5 + #631, #2119
  static MapaFase5 + #632, #2117
  static MapaFase5 + #633, #2117
  static MapaFase5 + #634, #2117
  static MapaFase5 + #635, #2117
  static MapaFase5 + #636, #2117
  static MapaFase5 + #637, #2117
  static MapaFase5 + #638, #2117
  static MapaFase5 + #639, #2115

  ;Linha 16
  static MapaFase5 + #640, #2119
  static MapaFase5 + #641, #2125
  static MapaFase5 + #642, #2117
  static MapaFase5 + #643, #2125
  static MapaFase5 + #644, #2117
  static MapaFase5 + #645, #2125
  static MapaFase5 + #646, #2117
  static MapaFase5 + #647, #2125
  static MapaFase5 + #648, #2117
  static MapaFase5 + #649, #2115
  static MapaFase5 + #650, #2119
  static MapaFase5 + #651, #2127
  static MapaFase5 + #652, #3967
  static MapaFase5 + #653, #3967
  static MapaFase5 + #654, #3967
  static MapaFase5 + #655, #3967
  static MapaFase5 + #656, #3967
  static MapaFase5 + #657, #3967
  static MapaFase5 + #658, #32
  static MapaFase5 + #659, #32
  static MapaFase5 + #660, #32
  static MapaFase5 + #661, #32
  static MapaFase5 + #662, #32
  static MapaFase5 + #663, #32
  static MapaFase5 + #664, #32
  static MapaFase5 + #665, #32
  static MapaFase5 + #666, #32
  static MapaFase5 + #667, #32
  static MapaFase5 + #668, #32
  static MapaFase5 + #669, #2091
  static MapaFase5 + #670, #2095
  static MapaFase5 + #671, #2119
  static MapaFase5 + #672, #2125
  static MapaFase5 + #673, #2125
  static MapaFase5 + #674, #2125
  static MapaFase5 + #675, #2125
  static MapaFase5 + #676, #2125
  static MapaFase5 + #677, #2125
  static MapaFase5 + #678, #2125
  static MapaFase5 + #679, #2115

  ;Linha 17
  static MapaFase5 + #680, #2119
  static MapaFase5 + #681, #2125
  static MapaFase5 + #682, #2117
  static MapaFase5 + #683, #2125
  static MapaFase5 + #684, #2117
  static MapaFase5 + #685, #2125
  static MapaFase5 + #686, #2117
  static MapaFase5 + #687, #2125
  static MapaFase5 + #688, #2117
  static MapaFase5 + #689, #2115
  static MapaFase5 + #690, #2089
  static MapaFase5 + #691, #2090
  static MapaFase5 + #692, #3967
  static MapaFase5 + #693, #3967
  static MapaFase5 + #694, #3967
  static MapaFase5 + #695, #3967
  static MapaFase5 + #696, #3967
  static MapaFase5 + #697, #3967
  static MapaFase5 + #698, #3967
  static MapaFase5 + #699, #3967
  static MapaFase5 + #700, #32
  static MapaFase5 + #701, #32
  static MapaFase5 + #702, #32
  static MapaFase5 + #703, #32
  static MapaFase5 + #704, #32
  static MapaFase5 + #705, #32
  static MapaFase5 + #706, #32
  static MapaFase5 + #707, #32
  static MapaFase5 + #708, #32
  static MapaFase5 + #709, #2127
  static MapaFase5 + #710, #2115
  static MapaFase5 + #711, #2119
  static MapaFase5 + #712, #2117
  static MapaFase5 + #713, #2117
  static MapaFase5 + #714, #2117
  static MapaFase5 + #715, #2117
  static MapaFase5 + #716, #2117
  static MapaFase5 + #717, #2117
  static MapaFase5 + #718, #2117
  static MapaFase5 + #719, #2115

  ;Linha 18
  static MapaFase5 + #720, #2119
  static MapaFase5 + #721, #2125
  static MapaFase5 + #722, #2117
  static MapaFase5 + #723, #2125
  static MapaFase5 + #724, #2117
  static MapaFase5 + #725, #2125
  static MapaFase5 + #726, #2117
  static MapaFase5 + #727, #2125
  static MapaFase5 + #728, #2117
  static MapaFase5 + #729, #2115
  static MapaFase5 + #730, #2119
  static MapaFase5 + #731, #2127
  static MapaFase5 + #732, #3967
  static MapaFase5 + #733, #3967
  static MapaFase5 + #734, #3967
  static MapaFase5 + #735, #3967
  static MapaFase5 + #736, #32
  static MapaFase5 + #737, #3967
  static MapaFase5 + #738, #3967
  static MapaFase5 + #739, #3967
  static MapaFase5 + #740, #3967
  static MapaFase5 + #741, #32
  static MapaFase5 + #742, #32
  static MapaFase5 + #743, #32
  static MapaFase5 + #744, #32
  static MapaFase5 + #745, #32
  static MapaFase5 + #746, #32
  static MapaFase5 + #747, #32
  static MapaFase5 + #748, #32
  static MapaFase5 + #749, #2090
  static MapaFase5 + #750, #2095
  static MapaFase5 + #751, #2119
  static MapaFase5 + #752, #2125
  static MapaFase5 + #753, #2125
  static MapaFase5 + #754, #2125
  static MapaFase5 + #755, #2125
  static MapaFase5 + #756, #2125
  static MapaFase5 + #757, #2125
  static MapaFase5 + #758, #2125
  static MapaFase5 + #759, #2115

  ;Linha 19
  static MapaFase5 + #760, #2119
  static MapaFase5 + #761, #2125
  static MapaFase5 + #762, #2117
  static MapaFase5 + #763, #2125
  static MapaFase5 + #764, #2117
  static MapaFase5 + #765, #2125
  static MapaFase5 + #766, #2117
  static MapaFase5 + #767, #2125
  static MapaFase5 + #768, #2117
  static MapaFase5 + #769, #2115
  static MapaFase5 + #770, #2089
  static MapaFase5 + #771, #2091
  static MapaFase5 + #772, #3967
  static MapaFase5 + #773, #3967
  static MapaFase5 + #774, #3967
  static MapaFase5 + #775, #32
  static MapaFase5 + #776, #32
  static MapaFase5 + #777, #32
  static MapaFase5 + #778, #3967
  static MapaFase5 + #779, #3967
  static MapaFase5 + #780, #3967
  static MapaFase5 + #781, #32
  static MapaFase5 + #782, #32
  static MapaFase5 + #783, #32
  static MapaFase5 + #784, #32
  static MapaFase5 + #785, #32
  static MapaFase5 + #786, #32
  static MapaFase5 + #787, #32
  static MapaFase5 + #788, #32
  static MapaFase5 + #789, #2127
  static MapaFase5 + #790, #2115
  static MapaFase5 + #791, #2119
  static MapaFase5 + #792, #2117
  static MapaFase5 + #793, #2117
  static MapaFase5 + #794, #2117
  static MapaFase5 + #795, #2117
  static MapaFase5 + #796, #2117
  static MapaFase5 + #797, #2117
  static MapaFase5 + #798, #2117
  static MapaFase5 + #799, #2115

  ;Linha 20
  static MapaFase5 + #800, #2119
  static MapaFase5 + #801, #2125
  static MapaFase5 + #802, #2117
  static MapaFase5 + #803, #2125
  static MapaFase5 + #804, #2117
  static MapaFase5 + #805, #2125
  static MapaFase5 + #806, #2117
  static MapaFase5 + #807, #2125
  static MapaFase5 + #808, #2117
  static MapaFase5 + #809, #2115
  static MapaFase5 + #810, #2119
  static MapaFase5 + #811, #2127
  static MapaFase5 + #812, #3967
  static MapaFase5 + #813, #3967
  static MapaFase5 + #814, #32
  static MapaFase5 + #815, #32
  static MapaFase5 + #816, #32
  static MapaFase5 + #817, #3967
  static MapaFase5 + #818, #3967
  static MapaFase5 + #819, #3967
  static MapaFase5 + #820, #3967
  static MapaFase5 + #821, #32
  static MapaFase5 + #822, #32
  static MapaFase5 + #823, #32
  static MapaFase5 + #824, #32
  static MapaFase5 + #825, #32
  static MapaFase5 + #826, #32
  static MapaFase5 + #827, #32
  static MapaFase5 + #828, #32
  static MapaFase5 + #829, #2091
  static MapaFase5 + #830, #2095
  static MapaFase5 + #831, #2119
  static MapaFase5 + #832, #2125
  static MapaFase5 + #833, #2125
  static MapaFase5 + #834, #2125
  static MapaFase5 + #835, #2125
  static MapaFase5 + #836, #2125
  static MapaFase5 + #837, #2125
  static MapaFase5 + #838, #2125
  static MapaFase5 + #839, #2115

  ;Linha 21
  static MapaFase5 + #840, #2119
  static MapaFase5 + #841, #2125
  static MapaFase5 + #842, #2117
  static MapaFase5 + #843, #2125
  static MapaFase5 + #844, #2117
  static MapaFase5 + #845, #2125
  static MapaFase5 + #846, #2117
  static MapaFase5 + #847, #2125
  static MapaFase5 + #848, #2117
  static MapaFase5 + #849, #2115
  static MapaFase5 + #850, #2089
  static MapaFase5 + #851, #2090
  static MapaFase5 + #852, #3967
  static MapaFase5 + #853, #32
  static MapaFase5 + #854, #32
  static MapaFase5 + #855, #32
  static MapaFase5 + #856, #32
  static MapaFase5 + #857, #32
  static MapaFase5 + #858, #32
  static MapaFase5 + #859, #32
  static MapaFase5 + #860, #32
  static MapaFase5 + #861, #32
  static MapaFase5 + #862, #32
  static MapaFase5 + #863, #32
  static MapaFase5 + #864, #32
  static MapaFase5 + #865, #32
  static MapaFase5 + #866, #32
  static MapaFase5 + #867, #32
  static MapaFase5 + #868, #32
  static MapaFase5 + #869, #2127
  static MapaFase5 + #870, #2115
  static MapaFase5 + #871, #2119
  static MapaFase5 + #872, #2117
  static MapaFase5 + #873, #2117
  static MapaFase5 + #874, #2117
  static MapaFase5 + #875, #2117
  static MapaFase5 + #876, #2117
  static MapaFase5 + #877, #2117
  static MapaFase5 + #878, #2117
  static MapaFase5 + #879, #2115

  ;Linha 22
  static MapaFase5 + #880, #2119
  static MapaFase5 + #881, #2125
  static MapaFase5 + #882, #2117
  static MapaFase5 + #883, #2125
  static MapaFase5 + #884, #2117
  static MapaFase5 + #885, #2125
  static MapaFase5 + #886, #2117
  static MapaFase5 + #887, #2125
  static MapaFase5 + #888, #2117
  static MapaFase5 + #889, #2115
  static MapaFase5 + #890, #2119
  static MapaFase5 + #891, #2127
  static MapaFase5 + #892, #32
  static MapaFase5 + #893, #32
  static MapaFase5 + #894, #3967
  static MapaFase5 + #895, #3967
  static MapaFase5 + #896, #3967
  static MapaFase5 + #897, #3967
  static MapaFase5 + #898, #3967
  static MapaFase5 + #899, #3967
  static MapaFase5 + #900, #3967
  static MapaFase5 + #901, #3967
  static MapaFase5 + #902, #3967
  static MapaFase5 + #903, #3876
  static MapaFase5 + #904, #32
  static MapaFase5 + #905, #32
  static MapaFase5 + #906, #32
  static MapaFase5 + #907, #32
  static MapaFase5 + #908, #32
  static MapaFase5 + #909, #2090
  static MapaFase5 + #910, #2095
  static MapaFase5 + #911, #2119
  static MapaFase5 + #912, #2125
  static MapaFase5 + #913, #2125
  static MapaFase5 + #914, #2125
  static MapaFase5 + #915, #2125
  static MapaFase5 + #916, #2125
  static MapaFase5 + #917, #2125
  static MapaFase5 + #918, #2125
  static MapaFase5 + #919, #2115

  ;Linha 23
  static MapaFase5 + #920, #2119
  static MapaFase5 + #921, #2125
  static MapaFase5 + #922, #2117
  static MapaFase5 + #923, #2125
  static MapaFase5 + #924, #2117
  static MapaFase5 + #925, #2125
  static MapaFase5 + #926, #2117
  static MapaFase5 + #927, #2125
  static MapaFase5 + #928, #2117
  static MapaFase5 + #929, #2115
  static MapaFase5 + #930, #2089
  static MapaFase5 + #931, #2091
  static MapaFase5 + #932, #3967
  static MapaFase5 + #933, #3967
  static MapaFase5 + #934, #3967
  static MapaFase5 + #935, #3967
  static MapaFase5 + #936, #3967
  static MapaFase5 + #937, #3967
  static MapaFase5 + #938, #3967
  static MapaFase5 + #939, #3967
  static MapaFase5 + #940, #3967
  static MapaFase5 + #941, #3967
  static MapaFase5 + #942, #3967
  static MapaFase5 + #943, #3876
  static MapaFase5 + #944, #32
  static MapaFase5 + #945, #32
  static MapaFase5 + #946, #32
  static MapaFase5 + #947, #32
  static MapaFase5 + #948, #32
  static MapaFase5 + #949, #2127
  static MapaFase5 + #950, #2115
  static MapaFase5 + #951, #2119
  static MapaFase5 + #952, #2117
  static MapaFase5 + #953, #2117
  static MapaFase5 + #954, #2117
  static MapaFase5 + #955, #2117
  static MapaFase5 + #956, #2117
  static MapaFase5 + #957, #2117
  static MapaFase5 + #958, #2117
  static MapaFase5 + #959, #2115

  ;Linha 24
  static MapaFase5 + #960, #2119
  static MapaFase5 + #961, #2125
  static MapaFase5 + #962, #2117
  static MapaFase5 + #963, #2125
  static MapaFase5 + #964, #2117
  static MapaFase5 + #965, #2125
  static MapaFase5 + #966, #2117
  static MapaFase5 + #967, #2125
  static MapaFase5 + #968, #2117
  static MapaFase5 + #969, #2115
  static MapaFase5 + #970, #2119
  static MapaFase5 + #971, #2127
  static MapaFase5 + #972, #3967
  static MapaFase5 + #973, #3967
  static MapaFase5 + #974, #3967
  static MapaFase5 + #975, #3967
  static MapaFase5 + #976, #3967
  static MapaFase5 + #977, #3967
  static MapaFase5 + #978, #3967
  static MapaFase5 + #979, #3967
  static MapaFase5 + #980, #3967
  static MapaFase5 + #981, #3967
  static MapaFase5 + #982, #3967
  static MapaFase5 + #983, #3967
  static MapaFase5 + #984, #32
  static MapaFase5 + #985, #32
  static MapaFase5 + #986, #32
  static MapaFase5 + #987, #32
  static MapaFase5 + #988, #32
  static MapaFase5 + #989, #2091
  static MapaFase5 + #990, #2095
  static MapaFase5 + #991, #2119
  static MapaFase5 + #992, #2125
  static MapaFase5 + #993, #2125
  static MapaFase5 + #994, #2125
  static MapaFase5 + #995, #2125
  static MapaFase5 + #996, #2125
  static MapaFase5 + #997, #2125
  static MapaFase5 + #998, #2125
  static MapaFase5 + #999, #2115

  ;Linha 25
  static MapaFase5 + #1000, #2119
  static MapaFase5 + #1001, #2125
  static MapaFase5 + #1002, #2117
  static MapaFase5 + #1003, #2125
  static MapaFase5 + #1004, #2117
  static MapaFase5 + #1005, #2125
  static MapaFase5 + #1006, #2117
  static MapaFase5 + #1007, #2125
  static MapaFase5 + #1008, #2117
  static MapaFase5 + #1009, #2115
  static MapaFase5 + #1010, #2089
  static MapaFase5 + #1011, #2090
  static MapaFase5 + #1012, #3967
  static MapaFase5 + #1013, #3967
  static MapaFase5 + #1014, #3967
  static MapaFase5 + #1015, #3967
  static MapaFase5 + #1016, #3967
  static MapaFase5 + #1017, #3967
  static MapaFase5 + #1018, #3967
  static MapaFase5 + #1019, #3967
  static MapaFase5 + #1020, #3967
  static MapaFase5 + #1021, #3967
  static MapaFase5 + #1022, #3967
  static MapaFase5 + #1023, #3967
  static MapaFase5 + #1024, #3876
  static MapaFase5 + #1025, #3876
  static MapaFase5 + #1026, #32
  static MapaFase5 + #1027, #32
  static MapaFase5 + #1028, #32
  static MapaFase5 + #1029, #2127
  static MapaFase5 + #1030, #2115
  static MapaFase5 + #1031, #2119
  static MapaFase5 + #1032, #2117
  static MapaFase5 + #1033, #2117
  static MapaFase5 + #1034, #2117
  static MapaFase5 + #1035, #2117
  static MapaFase5 + #1036, #2117
  static MapaFase5 + #1037, #2117
  static MapaFase5 + #1038, #2117
  static MapaFase5 + #1039, #2115

  ;Linha 26
  static MapaFase5 + #1040, #2119
  static MapaFase5 + #1041, #2125
  static MapaFase5 + #1042, #2117
  static MapaFase5 + #1043, #2125
  static MapaFase5 + #1044, #2117
  static MapaFase5 + #1045, #2125
  static MapaFase5 + #1046, #2117
  static MapaFase5 + #1047, #2125
  static MapaFase5 + #1048, #2117
  static MapaFase5 + #1049, #2115
  static MapaFase5 + #1050, #2119
  static MapaFase5 + #1051, #2127
  static MapaFase5 + #1052, #3967
  static MapaFase5 + #1053, #3967
  static MapaFase5 + #1054, #3967
  static MapaFase5 + #1055, #3967
  static MapaFase5 + #1056, #3967
  static MapaFase5 + #1057, #3967
  static MapaFase5 + #1058, #3967
  static MapaFase5 + #1059, #3967
  static MapaFase5 + #1060, #3967
  static MapaFase5 + #1061, #3967
  static MapaFase5 + #1062, #3967
  static MapaFase5 + #1063, #3967
  static MapaFase5 + #1064, #3967
  static MapaFase5 + #1065, #3876
  static MapaFase5 + #1066, #32
  static MapaFase5 + #1067, #32
  static MapaFase5 + #1068, #32
  static MapaFase5 + #1069, #2090
  static MapaFase5 + #1070, #2095
  static MapaFase5 + #1071, #2119
  static MapaFase5 + #1072, #2125
  static MapaFase5 + #1073, #2125
  static MapaFase5 + #1074, #2125
  static MapaFase5 + #1075, #2125
  static MapaFase5 + #1076, #2125
  static MapaFase5 + #1077, #2125
  static MapaFase5 + #1078, #2125
  static MapaFase5 + #1079, #2115

  ;Linha 27
  static MapaFase5 + #1080, #2119
  static MapaFase5 + #1081, #2125
  static MapaFase5 + #1082, #2117
  static MapaFase5 + #1083, #2125
  static MapaFase5 + #1084, #2117
  static MapaFase5 + #1085, #2125
  static MapaFase5 + #1086, #2117
  static MapaFase5 + #1087, #2125
  static MapaFase5 + #1088, #2117
  static MapaFase5 + #1089, #2115
  static MapaFase5 + #1090, #2089
  static MapaFase5 + #1091, #2091
  static MapaFase5 + #1092, #3967
  static MapaFase5 + #1093, #3967
  static MapaFase5 + #1094, #3967
  static MapaFase5 + #1095, #3967
  static MapaFase5 + #1096, #3967
  static MapaFase5 + #1097, #3967
  static MapaFase5 + #1098, #3967
  static MapaFase5 + #1099, #3967
  static MapaFase5 + #1100, #3967
  static MapaFase5 + #1101, #3967
  static MapaFase5 + #1102, #3967
  static MapaFase5 + #1103, #3967
  static MapaFase5 + #1104, #3967
  static MapaFase5 + #1105, #3967
  static MapaFase5 + #1106, #3876
  static MapaFase5 + #1107, #3967
  static MapaFase5 + #1108, #32
  static MapaFase5 + #1109, #2127
  static MapaFase5 + #1110, #2115
  static MapaFase5 + #1111, #2119
  static MapaFase5 + #1112, #2117
  static MapaFase5 + #1113, #2117
  static MapaFase5 + #1114, #2117
  static MapaFase5 + #1115, #2117
  static MapaFase5 + #1116, #2117
  static MapaFase5 + #1117, #2117
  static MapaFase5 + #1118, #2117
  static MapaFase5 + #1119, #2115

  ;Linha 28
  static MapaFase5 + #1120, #2119
  static MapaFase5 + #1121, #2125
  static MapaFase5 + #1122, #2117
  static MapaFase5 + #1123, #2125
  static MapaFase5 + #1124, #2117
  static MapaFase5 + #1125, #2125
  static MapaFase5 + #1126, #2117
  static MapaFase5 + #1127, #2125
  static MapaFase5 + #1128, #2117
  static MapaFase5 + #1129, #2115
  static MapaFase5 + #1130, #2119
  static MapaFase5 + #1131, #2127
  static MapaFase5 + #1132, #3967
  static MapaFase5 + #1133, #3967
  static MapaFase5 + #1134, #3967
  static MapaFase5 + #1135, #3967
  static MapaFase5 + #1136, #3967
  static MapaFase5 + #1137, #3967
  static MapaFase5 + #1138, #3967
  static MapaFase5 + #1139, #3967
  static MapaFase5 + #1140, #3967
  static MapaFase5 + #1141, #3967
  static MapaFase5 + #1142, #3967
  static MapaFase5 + #1143, #3967
  static MapaFase5 + #1144, #3967
  static MapaFase5 + #1145, #3967
  static MapaFase5 + #1146, #3967
  static MapaFase5 + #1147, #3876
  static MapaFase5 + #1148, #32
  static MapaFase5 + #1149, #2091
  static MapaFase5 + #1150, #2095
  static MapaFase5 + #1151, #2119
  static MapaFase5 + #1152, #2125
  static MapaFase5 + #1153, #2125
  static MapaFase5 + #1154, #2125
  static MapaFase5 + #1155, #2125
  static MapaFase5 + #1156, #2125
  static MapaFase5 + #1157, #2125
  static MapaFase5 + #1158, #2125
  static MapaFase5 + #1159, #2115

  ;Linha 29
  static MapaFase5 + #1160, #2119
  static MapaFase5 + #1161, #2054
  static MapaFase5 + #1162, #2054
  static MapaFase5 + #1163, #2054
  static MapaFase5 + #1164, #2054
  static MapaFase5 + #1165, #2054
  static MapaFase5 + #1166, #2054
  static MapaFase5 + #1167, #2054
  static MapaFase5 + #1168, #2054
  static MapaFase5 + #1169, #2115
  static MapaFase5 + #1170, #2089
  static MapaFase5 + #1171, #2090
  static MapaFase5 + #1172, #3967
  static MapaFase5 + #1173, #3967
  static MapaFase5 + #1174, #3967
  static MapaFase5 + #1175, #3967
  static MapaFase5 + #1176, #3967
  static MapaFase5 + #1177, #3967
  static MapaFase5 + #1178, #3967
  static MapaFase5 + #1179, #3967
  static MapaFase5 + #1180, #3967
  static MapaFase5 + #1181, #3967
  static MapaFase5 + #1182, #3967
  static MapaFase5 + #1183, #3967
  static MapaFase5 + #1184, #3967
  static MapaFase5 + #1185, #3967
  static MapaFase5 + #1186, #3967
  static MapaFase5 + #1187, #3967
  static MapaFase5 + #1188, #3876
  static MapaFase5 + #1189, #2127
  static MapaFase5 + #1190, #2115
  static MapaFase5 + #1191, #2119
  static MapaFase5 + #1192, #2054
  static MapaFase5 + #1193, #2054
  static MapaFase5 + #1194, #2054
  static MapaFase5 + #1195, #2054
  static MapaFase5 + #1196, #2054
  static MapaFase5 + #1197, #2054
  static MapaFase5 + #1198, #2054
  static MapaFase5 + #1199, #2115
