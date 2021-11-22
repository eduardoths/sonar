library ieee;
use ieee.std_logic_1164.all;

entity tx_dados_sonar_fd is 
	port (
		clock:           	in  std_logic; 
		reset:           	in  std_logic;
		zera:					in  std_logic; -- sinal de controle
		enviar_tx:			in  std_logic; -- sinal de controle
		incrementar_j:		in  std_logic; -- sinal de controle
		distancia2:      	in  std_logic_vector(7 downto 0); -- e de distancia  
		distancia1:      	in  std_logic_vector(7 downto 0); 
		distancia0:      	in  std_logic_vector(7 downto 0); 
		saida_serial:    	out std_logic; 
		tx_pronto:        out std_logic; -- sinal de condicao
		j_max:				out std_logic; -- sinal de condicao
		db_estado_tx:		out std_logic_vector(3 downto 0);
		db_estado_rx:		out std_logic_vector(3 downto 0)
	);
end entity;

architecture arch of tx_dados_sonar_fd is
	component uart_8N2 is
	  port (
			clock             : in std_logic;
			reset             : in std_logic;
			partida				: in std_logic;
			dados_ascii       : in std_logic_vector (7 downto 0);
			recebe_dado       : in std_logic;
			pronto_rx         : out std_logic;
			pronto_tx         : out std_logic;
			tem_dado          : out std_logic;
			dado_recebido     : out std_logic_vector (7 downto 0);
			saida_serial		: out std_logic;
			db_estado_tx		: out std_logic_vector(3 downto 0);
			db_estado_rx		: out std_logic_vector(3 downto 0)
	  );
	end component;

	component contador_m is
	    generic (
        constant M: integer := 50;  -- modulo do contador
        constant N: integer := 6    -- numero de bits da saida
		 );
		 port (
			  clock, zera, conta: in std_logic;
			  Q: out std_logic_vector (N-1 downto 0);
			  fim: out std_logic
		 );
	end component;
	
	component mux_4x1_n is
		generic (
			constant BITS: integer := 4
		);
		port ( 
			D0 :     in  std_logic_vector (BITS-1 downto 0);
			D1 :     in  std_logic_vector (BITS-1 downto 0);
			D2 :     in  std_logic_vector (BITS-1 downto 0);
			D3 :     in  std_logic_vector (BITS-1 downto 0);
			SEL:     in  std_logic_vector (2 downto 0);
			MUX_OUT: out std_logic_vector (BITS-1 downto 0)
		);
	end component;
	
	signal s_j: std_logic_vector(1 downto 0);
	signal s_dados_envio : std_logic_vector(7 downto 0);
	
	-- uart_8N2
	signal s_partida_uart, s_pronto_tx: std_logic;

	-- mux
	signal s_ang2, s_ang1, s_ang0, s_d2, s_d1, s_d0: std_logic_vector(7 downto 0);
begin
	s_d2 <=   distancia2;
	s_d1 <=   distancia1;
	s_d0 <=   distancia0;
	
	network: uart_8N2 port map (
		clock 			=> clock,
		reset				=> zera,
		partida 			=> enviar_tx,
		dados_ascii 	=> s_dados_envio,
		recebe_dado		=> '0',
		pronto_rx		=> open,
		pronto_tx 		=> tx_pronto,
		tem_dado			=> open,
		dado_recebido	=> open,
		saida_serial	=> saida_serial,
		db_estado_tx	=> db_estado_tx,
		db_estado_rx	=> db_estado_rx
	);

	j: contador_m
		generic map (
			M => 4,
			N => 2
		)
		port map (
			clock => clock,
			zera	=> zera,
			conta => incrementar_j,
			Q		=> s_j,
			fim	=> j_max
		);
	
	mux: mux_8x1_n
		generic map (BITS => 8)
		port map (
			D0			=> s_d2,
			D1			=> s_d1,
			D2			=> s_d0,
			D3			=> "00101110",
			SEL 		=> s_j,
			MUX_OUT 	=> s_dados_envio
		);
end architecture;