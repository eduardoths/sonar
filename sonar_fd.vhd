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
		medir:			 		in  std_logic;
		entrada_serial:			in  std_logic;
        echo:         			in  std_logic; 
        trigger:      			out std_logic;  
        pwm:          			out std_logic; 
		pronto_sensor:			out std_logic;
		pronto_servo: 			out std_logic;
        saida_serial: 			out std_logic;
		-- Depuracao
		distancia2:				out std_logic_vector(3 downto 0);	
		distancia1:				out std_logic_vector(3 downto 0);
		distancia0:				out std_logic_vector(3 downto 0);
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
        posicao:       	in  std_logic;
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

	component comandos is
		port (
			reset:      in  std_logic;
			comando:    in  std_logic_vector(7 downto 0);
			aberto:     out std_logic;
			manual:     out std_logic;
			inverter:   out std_logic
		);
	end component;

	component rx_serial_8N2
        port ( 
            clock:         in  std_logic;  
            reset:         in  std_logic; 
            dado_serial:   in  std_logic; 
            recebe_dado:   in  std_logic; 
            pronto_rx:     out std_logic; 
            tem_dado:      out std_logic; 
            dado_recebido: out std_logic_vector (7 downto 0); 
            db_estado:     out std_logic_vector (3 downto 0)  -- estado da UC 
        ); 
    end component; 
  
  signal s_distancia1, s_distancia0, s_distancia2: std_logic_vector(7 downto 0);

  	signal s_medida : std_logic_vector(11 downto 0);
	signal s_rom: std_logic_vector(23 downto 0);
	signal s_posicao: std_logic;

	--
	signal s_abre, s_manual, s_inverter: std_logic;
	signal s_dado_recebido: std_logic_vector(7 downto 0);
	signal s_proximo: std_logic;
begin
	with s_manual select s_posicao <=
		s_inverter xor s_abre when '1',
		s_proximo when others;

	U1_TX: tx_dados_sonar 
		port map (
			clock, 
			reset, 
			transmitir, 
			s_distancia2, 
			s_distancia1, 
			s_distancia0, 
			saida_serial, 
			open, 
			open, 
			open,
			estado_tx_sonar,
			estado_tx,
			open
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
	
	registrador_comandos : comandos port map (
		reset     => reset,
		comando   => s_dado_recebido,
		aberto    => s_abre,
		manual    => s_manual,
		inverter  => s_inverter
	  );
	  
	  recepcao: rx_serial_8N2 port map(
		clock           => clock,
		reset           => reset,
		dado_serial     => entrada_serial,
		recebe_dado     => '1',
		pronto_rx       => open,
		tem_dado        => open,
		dado_recebido   => s_dado_recebido,
		db_estado       => estado_rx
	  );
																  	
	-- distancia
	s_distancia0 <= x"3" & s_medida(3 downto 0);
	s_distancia1 <= x"3" & s_medida(7 downto 4);
	s_distancia2 <= x"3" & s_medida(11 downto 8);
															
	s_proximo <= 
		'1' when (s_distancia1 = "00110001" or s_distancia1 = "00110000") and s_distancia2 = "00110000" 
		else '0';
	
	-- Depuracao
	distancia2 <= s_distancia2(3 downto 0); 
	distancia1 <= s_distancia1(3 downto 0);
	distancia0 <= s_distancia0(3 downto 0);
end architecture;