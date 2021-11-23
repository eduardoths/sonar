library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_serial_8N2 is
  port (
    clock             : in std_logic;
    reset             : in std_logic;
    dado_serial       : in std_logic;
    recebe_dado       : in std_logic;
    pronto_rx         : out std_logic;
    tem_dado          : out std_logic;
    dado_recebido     : out std_logic_vector (7 downto 0);
    db_estado         : out std_logic_vector (3 downto 0)
  );
end entity;

architecture rx_serial_8N2_architecture of rx_serial_8N2 is
  component contadorg_m
    generic (
      constant M : integer
    );
    port (
      clock, zera_as, zera_s, conta : in std_logic;
      Q                             : out std_logic_vector(natural(ceil(log2(real(M)))) - 1 downto 0);
      fim, meio                     : out std_logic
    );
  end component;

  component rx_serial_8N2_uc
    port (
      clock, reset, dado, tick, fim, recebe_dado                       : in std_logic;
      limpa, carrega, zera, desloca, conta, registra, pronto, tem_dado : out std_logic;
      db_estado                                                        : out std_logic_vector(3 downto 0)
    );
  end component;

  component rx_serial_8N2_fd
    port (
      clock, reset, recebe_dado                      : in std_logic;
      zera, conta, registra, limpa, carrega, desloca : in std_logic;
      dado_serial                                    : in std_logic;
      saida_serial                                   : out std_logic_vector(7 downto 0);
      pronto                                         : out std_logic;
      Q                                              : out std_logic_vector(3 downto 0)
    );
  end component;

  component hex7seg
    port (
      hexa : in std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
    );
  end component;

  signal s_estado                                                                            : std_logic_vector(3 downto 0);
  signal s_tick, limpa_uc, carrega_uc, zera_uc, desloca_uc, conta_uc, registra_uc, pronto_fd : std_logic;

begin
  contador : contadorg_m generic map(
    M => 5208
    ) port map (
    clock   => clock,
    zera_as => '0',
    zera_s  => zera_uc,
    conta   => '1',
    Q       => open,
    fim     => open,
    meio    => s_tick
  );

  uc : rx_serial_8N2_uc port map(
    clock       => clock,
    reset       => reset,
    dado        => dado_serial,
    tick        => s_tick,
    fim         => pronto_fd,
    recebe_dado => recebe_dado,
    limpa       => limpa_uc,
    carrega     => carrega_uc,
    zera        => zera_uc,
    desloca     => desloca_uc,
    conta       => conta_uc,
    registra    => registra_uc,
    pronto      => pronto_rx,
    tem_dado    => tem_dado,
    db_estado   => s_estado
  );

  fd : rx_serial_8N2_fd port map(
    clock        => clock,
    reset        => reset,
    recebe_dado  => recebe_dado,
    zera         => zera_uc,
    conta        => conta_uc,
    registra     => registra_uc,
    limpa        => limpa_uc,
    carrega      => carrega_uc,
    desloca      => desloca_uc,
    dado_serial  => dado_serial,
    saida_serial => dado_recebido,
    pronto       => pronto_fd,
    Q            => open
  );

  db_estado <= s_estado;
end architecture;