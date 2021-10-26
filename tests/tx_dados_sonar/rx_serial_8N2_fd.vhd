library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_serial_8N2_fd is
  port (
    clock, reset, recebe_dado                      : in std_logic;
    zera, conta, registra, limpa, carrega, desloca : in std_logic;
    dado_serial                                    : in std_logic;
    saida_serial                                   : out std_logic_vector(7 downto 0);
    pronto                                         : out std_logic;
    Q                                              : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rx_serial_8N2_fd_architecture of rx_serial_8N2_fd is

  component deslocador_n
    generic (
      constant N : integer
    );
    port (
      clock, reset                     : in std_logic;
      carrega, desloca, entrada_serial : in std_logic;
      dados                            : in std_logic_vector(N - 1 downto 0);
      saida                            : out std_logic_vector(N - 1 downto 0)
    );
  end component;

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

  component registrador_n
    generic (
      constant N : integer
    );
    port (
      clock, clear, enable : in std_logic;
      D                    : in std_logic_vector(N - 1 downto 0);
      Q                    : out std_logic_vector(N - 1 downto 0)
    );
  end component;

  signal s_dado : std_logic_vector(10 downto 0);

begin
  deslocador : deslocador_n generic map(
    N => 11
    ) port map(
    clock          => clock,
    reset          => reset,
    carrega        => carrega,
    desloca        => desloca,
    entrada_serial => dado_serial,
    dados          => "00000000000",
    saida          => s_dado
  );

  contador : contadorg_m generic map(
    M => 11
    ) port map (
    clock,
    '0',
    zera,
    conta,
    Q,
    pronto,
    open
  );

  registrador : registrador_n generic map(
    N => 8
    ) port map (
    clock,
    limpa,
    registra,
    s_dado(9 downto 2),
    saida_serial
  );

end architecture;