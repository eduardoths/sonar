library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity sonar_fd is 
    port( 
        clock:        			in  std_logic; 
        reset:        			in  std_logic; 
        conta:        			in  std_logic; 
		  transmitir:   			in  std_logic;
		  medir:			 			in  std_logic;
        echo:         			in  std_logic; 
        trigger:      			out std_logic;  
        pwm:          			out std_logic; 
		  pronto_sensor:			out std_logic;
		  pronto_servo: 			out std_logic;
        saida_serial: 			out std_logic;
		  alerta_proximidade: 	out std_logic;
		  -- Depuracao
		  distancia2:				out std_logic_vector(3 downto 0);	
		  distancia1:				out std_logic_vector(3 downto 0);
		  distancia0:				out std_logic_vector(3 downto 0);
		  angulo2:					out std_logic_vector(3 downto 0);
		  angulo1:					out std_logic_vector(3 downto 0);
		  angulo0:					out std_logic_vector(3 downto 0);
		  posicao:					out std_logic_vector(3 downto 0);
		  estado_hcsr04:			out std_logic_vector(3 downto 0);
		  estado_tx:				out std_logic_vector(3 downto 0);
		  estado_rx:				out std_logic_vector(3 downto 0);
		  estado_tx_sonar:		out std_logic_vector(3 downto 0)
    ); 
end entity;

architecture estrutural of sonar_fd is
	component tx_dados_sonar 
		port ( 
			clock:           	in  std_logic; 
			reset:           	in  std_logic; 
			transmitir:      	in  std_logic; 
			angulo2:         	in  std_logic_vector(7 downto 0); -- digitos ASCII 
			angulo1:         	in  std_logic_vector(7 downto 0); -- de angulo 
			angulo0:         	in  std_logic_vector(7 downto 0); 
			distancia2:      	in  std_logic_vector(7 downto 0); -- e de distancia  
			distancia1:      	in  std_logic_vector(7 downto 0); 
			distancia0:      	in  std_logic_vector(7 downto 0); 
			saida_serial:    	out std_logic; 
			pronto:          	out std_logic;  
			db_transmitir:   	out std_logic; 
			db_saida_serial: 	out std_logic; 
			db_estado:		  	out std_logic_vector(3 downto 0);
			db_estado_tx:	  	out std_logic_vector(3 downto 0);
			db_estado_rx:    	out std_logic_vector(3 downto 0)
		); 
	end component;
	
	component interface_hcsr04 
		port ( 
		clock:     in  std_logic;  
		reset:     in  std_logic; 
		medir:     in  std_logic; 
		echo:      in  std_logic; 
		trigger:   out std_logic; 
		medida:    out std_logic_vector(11 downto 0);
		pronto:    out std_logic; 
		db_estado: out std_logic_vector(3 downto 0)
    ); 
	end component;

	component movimentacao_servomotor 
		port ( 
        clock:         	in  std_logic;  
        reset:         	in  std_logic; 
        ligar:   	 	  	in  std_logic;
        posicao:       	out std_logic_vector (2 downto 0);
        pwm:           	out std_logic; 
		  pronto1s:		  	out std_logic
		);
	end component;

	component contadorg_m 
		generic (
			constant M: integer := 50 -- modulo do contador
		);
		port (
			clock, zera_as, zera_s, conta: in std_logic;
			Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
			fim, meio: out std_logic 
		);
	end component;
	
	component rom_8x24 
		port ( 
        endereco: in  std_logic_vector(2 downto 0);
        saida   : out std_logic_vector(23 downto 0)
		);
	end component;
  
  signal s_angulo2, s_angulo1, s_angulo0: std_logic_vector(7 downto 0);
  signal s_distancia1, s_distancia0, s_distancia2: std_logic_vector(7 downto 0);

  	signal s_medida : std_logic_vector(11 downto 0);
	signal s_rom: std_logic_vector(23 downto 0);
	signal s_posicao: std_logic_vector(2 downto 0);
begin

	U1_TX: tx_dados_sonar 
		port map (
			clock, 
			reset, 
			transmitir, 
			s_angulo2, 
			s_angulo1, 
			s_angulo0,
			s_distancia2, 
			s_distancia1, 
			s_distancia0, 
			saida_serial, 
			open, 
			open, 
			open,
			estado_tx_sonar,
			estado_tx,
			estado_rx
		);						  
	
	U1_IH: interface_hcsr04 
		port map (
			clock, 
			reset, 
			medir, 
			echo,
			trigger, 
			s_medida, 
			pronto_sensor, 
			estado_hcsr04
		);
	
	U2_MS: movimentacao_servomotor 
		port map (
			clock, 
			reset, 
			conta, 
			s_posicao, 
			pwm, 
			pronto_servo
		);
																  
				
	U3_ROM: rom_8x24 port map(s_posicao, s_rom);
	
	-- distancia
	s_distancia0 <= x"3" & s_medida(3 downto 0);
	s_distancia1 <= x"3" & s_medida(7 downto 4);
	s_distancia2 <= x"3" & s_medida(11 downto 8);
	
	-- angulo
	s_angulo2 <= s_rom(23 downto 16);
	s_angulo1 <= s_rom(15 downto 8);
	s_angulo0 <= s_rom(7 downto 0);
															
	alerta_proximidade <= 
		'1' when (s_distancia1 = "00110001" or s_distancia1 = "00110000") and s_distancia2 = "00110000" 
		else '0';
	
	-- Depuracao
	distancia2 <= s_distancia2(3 downto 0); 
	distancia1 <= s_distancia1(3 downto 0);
	distancia0 <= s_distancia0(3 downto 0);
	angulo2 <= s_angulo2(3 downto 0);
	angulo1 <= s_angulo1(3 downto 0);
	angulo0 <= s_angulo0(3 downto 0);
	posicao <= '0' & s_posicao;
end architecture;