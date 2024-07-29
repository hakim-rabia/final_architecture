library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env_tb is
end test_env_tb;

architecture Behavioral of test_env_tb is

    component test_env
        Port ( clk : in STD_LOGIC;
               btn : in STD_LOGIC_VECTOR (4 downto 0);
               sw : in STD_LOGIC_VECTOR (15 downto 0);
               led : out STD_LOGIC_VECTOR (15 downto 0);
               an : out STD_LOGIC_VECTOR (3 downto 0);
               cat : out STD_LOGIC_VECTOR (6 downto 0));
    end component;

    -- Testbench signals
    signal clk_tb : STD_LOGIC := '0';
    signal btn_tb : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
    signal sw_tb : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal led_tb : STD_LOGIC_VECTOR (15 downto 0);
    signal an_tb : STD_LOGIC_VECTOR (3 downto 0);
    signal cat_tb : STD_LOGIC_VECTOR (6 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    uut: test_env
        Port map (
            clk => clk_tb,
            btn => btn_tb,
            sw => sw_tb,
            led => led_tb,
            an => an_tb,
            cat => cat_tb
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 20 ns.
        btn_tb(1) <= '1'; -- Reset signal
        wait for 20 ns;
        btn_tb(1) <= '0'; -- Release reset

        -- apply inputs
        wait for 10 ns;
        btn_tb(0) <= '1'; -- Set enable
        wait for 10 ns;
        btn_tb(0) <= '0';

        -- Provide some time for the pipeline to process instructions
        wait for 200 ns;

        -- Test different switch settings to check various internal states
        sw_tb(7 downto 5) <= "000"; -- Check current instruction
        wait for 10 ns;
        sw_tb(7 downto 5) <= "001"; -- Check next instruction
        wait for 10 ns;
        sw_tb(7 downto 5) <= "010"; -- Check the RD1 signal
        wait for 10 ns;
        sw_tb(7 downto 5) <= "011"; -- Check the RD2 signal
        wait for 10 ns;
        sw_tb(7 downto 5) <= "100"; -- Check ExtImm
        wait for 10 ns;
        sw_tb(7 downto 5) <= "101"; -- Check ALU result
        wait for 10 ns;
        sw_tb(7 downto 5) <= "110"; -- Check memory data
        wait for 10 ns;
        sw_tb(7 downto 5) <= "111"; -- Check write data
        wait for 10 ns;

        -- End of simulation
        wait;
    end process;

end Behavioral;
