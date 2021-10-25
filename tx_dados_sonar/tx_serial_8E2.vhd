library ieee;
use ieee.std_logic_1164.all;


entity tx_serial_8E2 is
    port (
        clock, reset, partida: in  std_logic;
		  config_modo:				 in  std_logic;
        dados_ascii:           in  std_logic_vector (7 downto 0);
        saida_serial, pronto : out std_logic;
		  db_estado: 				 out std_logic_vector(3 downto 0)
    );
end entity;

architecture tx_serial_8E2_arch of tx_serial_8E2 is
     
    component tx_serial_tick_uc port ( 
            clock, reset, partida, tick, fim:      in  std_logic;
            zera, conta, carrega, desloca, pronto: out std_logic;
				db_estado: out std_logic_vector (3 downto 0)
    );
    end component;

    component tx_serial_8E2_fd port (
        clock, reset: in std_logic;	
        zera, conta, carrega, desloca: in std_logic;
		  config_modo: in std_logic;
        dados_ascii: in std_logic_vector (7 downto 0);
        saida_serial, fim : out std_logic
    );
    end component;
    
    component contador_m
    generic (
        constant M: integer; 
        constant N: integer 
    );
    port (
        clock, zera, conta: in std_logic;
        Q: out std_logic_vector (N-1 downto 0);
        fim: out std_logic
    );
    end component;
    
    component edge_detector is port ( 
             clk         : in   std_logic;
             signal_in   : in   std_logic;
             output      : out  std_logic
    );
    end component;    
    signal s_reset, s_partida, s_partida_ed: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_fim: std_logic;
	signal s_serial, s_tick : std_logic;
begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset   <= reset;
    s_partida <= partida;
	
    -- unidade de controle
    U1_UC: tx_serial_tick_uc port map (
		clock =>clock, 
		reset => s_reset, 
		partida => s_partida_ed,
		fim => s_fim,
		tick => s_tick,
		zera => s_zera, 
		conta => s_conta, 
		carrega => s_carrega, 
		desloca => s_desloca, 
		pronto => pronto,
		db_estado => db_estado);

    -- fluxo de dados
    U2_FD: tx_serial_8E2_fd port map (
		clock => clock, 
		reset=> s_reset, 
		zera => s_zera, 
		conta => s_conta, 
		carrega => s_carrega, 
		desloca => s_desloca, 
		config_modo => config_modo,
		dados_ascii => dados_ascii, 
		saida_serial => s_serial, 
		fim => s_fim);
	
	U3_TICK: contador_m generic map (M => 5208, N => 13) port map (clock, s_zera,'1', open, s_tick);
   
	-- detetor de borda para tratar pulsos largos
    U4_ED: edge_detector port map (clock, s_partida, s_partida_ed);	
	saida_serial <= s_serial;
end architecture;

