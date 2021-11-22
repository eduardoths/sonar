library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity projeto_1_rx_tb is
end entity;

architecture test of projeto_1_rx_tb is
    component sonar
        port (
            clock:        		in  std_logic; 
            reset:        		in  std_logic; 
            ligar:        		in  std_logic; 
            echo:         		in  std_logic; 
            entrada_serial:		in  std_logic;
            trigger:      		out std_logic;  
            pwm:          		out std_logic; 
            saida_serial: 		out std_logic;
            hex0:			 	out std_logic_vector(6 downto 0);
            hex1:			 	out std_logic_vector(6 downto 0);
            hex2:			 	out std_logic_vector(6 downto 0);
            hex3:			 	out std_logic_vector(6 downto 0);
            hex4:			 	out std_logic_vector(6 downto 0);
            hex5:			 	out std_logic_vector(6 downto 0)
        );
    end component;


    -- aux testing component
    component tx_serial_8E2 is
        port (
            clock:          in  std_logic;
            reset:          in  std_logic;
            partida:        in  std_logic;
            config_modo:    in  std_logic;
            dados_ascii:    in  std_logic_vector (7 downto 0);
            saida_serial:   out std_logic;
            pronto :        out std_logic;
            db_estado:      out std_logic_vector(3 downto 0)
        );
    end component;


    signal clock_in: std_logic := '0';
    signal reset_in: std_logic := '0';
    signal start_in: std_logic := '0';
    signal echo_in: std_logic := '1';
    signal trigger_out: std_logic := '0';
    signal pwm_out: std_logic := '0'; 
    signal posicao_out: std_logic := '0';
    signal saida_serial_out: std_logic := '0'; 
    signal dist0_out, dist1_out, dist2_out: std_logic_vector(6 downto 0);
    signal est_hcsr04_out, est_tx_out, est_rx_out, estado_out: std_logic_vector (6 downto 0);
    signal dado_ascii_out : std_logic_vector(7 downto 0) := "00000000";

    -- aux tx
    signal aux_tx_partida: std_logic := '0';
    signal aux_ascii_in: std_logic_vector(7 downto 0) := "01000001";
    signal aux_tx_serial: std_logic;
    signal aux_tx_pronto: std_logic;

    type caso_teste_type is record
        id      : natural; 
        msg     : std_logic_vector(7 downto 0);     
    end record;
    type casos_teste_array is array (natural range <>) of caso_teste_type;
    constant casos_teste : casos_teste_array :=
        (
            (1, x"61"),	 -- "a" - abre
            (2, x"66"),	 -- "f" - fecha
            (3, x"6A"),	 -- "i" - inverte
            (4, x"6A"),	 -- "i" - inverte
            (5, x"6D"),	 -- "m" - manual
            (6, x"41")	 -- "A" - automático
        );
    signal larguraPulso: time := 1 ns;
    -- Configurações do clock
    signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
    constant clockPeriod : time := 20 ns;     -- clock de 50MHz

begin
    DUT: sonar port map (
        clock           => clock_in,
        reset           => reset_in,
        ligar           => start_in,
        echo            => echo_in,
		entrada_serial  => aux_tx_serial,
        trigger         => trigger_out,
        pwm             => pwm_out,
        saida_serial    => saida_serial_out,
		hex0            => open,
		hex1            => open,
		hex2            => open,
		hex3            => open,
		hex4            => open,
		hex5            => open
    );


    aux_tx: tx_serial_8E2 port map (
        clock           => clock_in,
        reset           => reset_in,
        partida         => aux_tx_partida,
        config_modo     => '0',
        dados_ascii     => aux_ascii_in,
        saida_serial    => aux_tx_serial,
        pronto          => aux_tx_pronto,
        db_estado       => open
    );

    clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
    stimulus: process is
    begin
        assert false report "Inicio das simulacoes" severity note;
        keep_simulating <= '1';
        
        ---- valores iniciais ----------------
        start_in <= '0';
        echo_in  <= '0';

        ---- inicio: reset ----------------
        wait for 2*clockPeriod;
        reset_in <= '1'; 
        wait for 2 us;
        reset_in <= '0';
        wait until falling_edge(clock_in);

        ---- espera de 100us
        aux_tx_partida <= '0';
        wait for 100 us;

        ---- loop pelos casos de teste
        for i in casos_teste'range loop
             -- 1) determina largura do pulso echo
            assert false report "Caso de teste " & integer'image(casos_teste(i).id) severity note;
            wait until falling_edge(clock_in);

            aux_ascii_in <= casos_teste(i).msg;
            wait for 1 * clockPeriod;
            aux_tx_partida <= '1';

            wait until aux_tx_pronto='1' for 1 ms;
            
            
            assert false report "Fim do caso " & integer'image(casos_teste(i).id) severity note;
        
            -- 6) espera entre casos de tese
            aux_tx_partida <= '0';
            wait for 100 us;

        end loop;
    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;

  
end architecture;
