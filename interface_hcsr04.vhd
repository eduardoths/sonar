library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04 is
  port (
    clock     : in std_logic;
    reset     : in std_logic;
    medir     : in std_logic;
    echo      : in std_logic;
    trigger   : out std_logic;
    medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
    pronto    : out std_logic;
    db_estado : out std_logic_vector(3 downto 0) -- estado da UC
  );
end interface_hcsr04;

architecture interface_hcsr04_arch of interface_hcsr04 is
  signal s_pulso_subida, s_pulso_descida, s_gera_pulso, s_mede_distancia, s_zera : std_logic;

  component interface_hcsr04_uc
    port (
      clock, reset, medir                      : in std_logic;
      pulso_subida, pulso_descida              : in std_logic;
      gera_pulso, mede_distancia, pronto, zera : out std_logic;
      db_estado                                : out std_logic_vector(3 downto 0)
    );
  end component;

  component interface_hcsr04_fd
    port (
      clock, reset, echo, gera_pulso, mede_distancia, zera : in std_logic;
      pulso_subida, pulso_descida                          : out std_logic;
      trigger                                              : out std_logic;
      medida                                               : out std_logic_vector(11 downto 0)
    );
  end component;

begin
  uc : interface_hcsr04_uc port map(
    clock,
    reset,
    medir,
    s_pulso_subida,
    s_pulso_descida,
    s_gera_pulso,
    s_mede_distancia,
    pronto,
    s_zera,
    db_estado
  );

  fd : interface_hcsr04_fd port map(
    clock,
    reset,
    echo,
    s_gera_pulso,
    s_mede_distancia,
    s_zera,
    s_pulso_subida,
    s_pulso_descida,
    trigger,
    medida
  );

end interface_hcsr04_arch;