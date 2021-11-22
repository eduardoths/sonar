library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity movimentacao_servomotor is
  port (
    reset : in std_logic;
    clock : in std_logic;
	ligar : in std_logic;
    posicao: in std_logic;
    pwm : out std_logic;
	pronto1s: out std_logic
  );
end entity;

architecture circuit of movimentacao_servomotor is

  signal s_fim : std_logic;
  signal s_pwm : std_logic;

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

  component contadorg_updown_m
    generic (
      constant M : integer := 50 -- modulo do contador
    );
    port (
      clock : in std_logic;
      zera_as : in std_logic;
      zera_s : in std_logic;
      conta : in std_logic;
      Q : out std_logic_vector (natural(ceil(log2(real(M)))) - 1 downto 0);
      inicio : out std_logic;
      fim : out std_logic;
      meio : out std_logic
    );
  end component;

  component controle_servo
    port (
      clock : in std_logic;
      reset : in std_logic;
      posicao : in std_logic;
      pwm : out std_logic
    );
  end component;

begin

  c1s : contadorg_m generic map(
    M => 50000000
    ) port map(
    clock,
    reset,
    '0',
    ligar,
    open,
    s_fim,
    open
  );

  cs : controle_servo port map(
    clock,
    reset,
    posicao,
    s_pwm
  );

  pwm <= s_pwm;
  pronto1s <= s_fim;
end architecture;