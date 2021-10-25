library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity interface_hcsr04_fd is
  port (
    clock, reset, echo, gera_pulso, mede_distancia, zera : in std_logic;
    pulso_subida, pulso_descida : out std_logic;
    trigger : out std_logic;
    medida : out std_logic_vector(11 downto 0)
  );
end interface_hcsr04_fd;

architecture interface_hcsr04_fd_arch of interface_hcsr04_fd is
  signal s_pronto : std_logic;
  signal s_contagem : std_logic;
  signal s_medida, medida_salva : std_logic_vector(11 downto 0);

  component contadorg_m
    generic (
      constant M : integer := 50 -- modulo do contador
    );
    port (
      clock, zera_as, zera_s, conta : in std_logic;
      Q : out std_logic_vector (natural(ceil(log2(real(M)))) - 1 downto 0);
      fim, meio : out std_logic
    );
  end component;

  component contador_bcd_4digitos
    port (
      clock, zera, conta : in std_logic;
      dig3, dig2, dig1, dig0 : out std_logic_vector(3 downto 0);
      fim : out std_logic
    );
  end component;

  component gerador_pulso
    generic (
      largura : integer
    );
    port (
      clock, reset : in std_logic;
      gera, para : in std_logic;
      pulso, pronto : out std_logic
    );
  end component;

  component registrador_n
    generic (
      constant N : integer := 8
    );
    port (
      clock : in std_logic;
      clear : in std_logic;
      enable : in std_logic;
      D : in std_logic_vector (N - 1 downto 0);
      Q : out std_logic_vector (N - 1 downto 0)
    );
  end component;
  
  component edge_detector
      port ( clk         : in   std_logic;
           signal_in   : in   std_logic;
           output      : out  std_logic
    );
	end component;

begin

  cont : contadorg_m generic map(
    M => 2941
    ) port map(
    clock,
    '0',
    zera,
    mede_distancia,
    open,
    s_pronto,
    open
  );

  bcd : contador_bcd_4digitos port map(
    clock,
    zera,
    s_pronto,
    open,
    s_medida(11 downto 8),
    s_medida(7 downto 4),
    s_medida(3 downto 0),
    open
  );

  gp : gerador_pulso generic map(
    largura => 500
    ) port map(
    clock,
    reset,
    gera_pulso,
    '0',
    trigger,
    open
  );

  rg : registrador_n generic map(
    n => 12
    ) port map(
    clock,
    zera,
    mede_distancia,
    s_medida,
	 medida_salva
  );
  
  ps_s: edge_detector port map (
	clock,
	echo,
	pulso_subida
  );
  
  ps_d: edge_detector port map (
	clock,
	not(echo),
	pulso_descida
  );
  
  medida <= medida_salva;

end interface_hcsr04_fd_arch;