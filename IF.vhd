library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity IFetch is
    Port ( jump: in std_logic;
          jumpAddress: in std_logic_vector (15 downto 0);
          PCSrc: in std_logic;
          BranchAddress: in std_logic_vector (15 downto 0);
          en: in std_logic;
          rst: in std_logic;
          clk: in std_logic;
          instr: out std_logic_vector (15 downto 0);
          next_instr: out std_logic_vector (15 downto 0) );
end IFetch;

architecture Behavioral of IFetch is
signal d: std_logic_vector(15 downto 0):=x"0000";
signal q: std_logic_vector(15 downto 0):=x"0000";
signal m1: std_logic_vector(15 downto 0); 
signal pc:std_logic_vector(15 downto 0);
type rom is array (0 to 29) of std_logic_vector(15 downto 0);
--Initialize R1 with 10
--Initialize R2 with 15
--NoOP
--NoOp
--Put in R3 the value R2-R1, which is 5
--Put in R4 the value R2+R1, which is 25
--NoOp
--Store at address 6+R1=16 in memory the value of R3, which is 5
--Load into memory in R2 the value from address R2+1=16, which is 5 => R2=5
--Shift R1 to the right by one position => R1=R1/2=10/2=5
--NoOp
--NoOp
--If R1=R2 then jump 2 instructions from the current position
--NoOp
--NoOp
--NoOp
--Jump to the instruction with index 7, which is the 8th in the code
--NoOp
--Store at address R1+2=7 the value of R1, which is 5
--Put in R4 the value R4-R2, which is 20
--Shift R1 to the left by one position => R1=R1*2=10
--NoOp
--NoOp
--If R1=R4 then jump 2 instructions from the current position
--NoOp
--NoOp
--NoOp
--Jump to the instruction with index 20, which is the 21st in the code
--NoOp
--Store in memory at address 5 the value of R1, which is 20  
signal mem_rom: rom := (
    x"208A", -- addi $1,$0,10 
    x"210F", -- addi $2,$0,15
    x"0000", -- add $0,$0,$0
    x"0000", -- add $0,$0,$0
    x"08B1", -- sub $3,$2,$1
    x"08C0", -- add $4,$2,$1
    x"0000", -- add $0,$0,$0
    x"6586", -- sw $3,6($1) 
    x"4901", -- lw $2,1($2)
    x"049B", -- srl $1,$1,1
    x"0000", -- add $0,$0,$0
    x"0000", -- add $0,$0,$0
    x"8504", -- beq $1,$2,4
    x"0000", -- add $0,$0,$0
    x"0000", -- add $0,$0,$0
    x"0000", -- add $0,$0,$0
    x"E007", -- j 7
    x"0000", -- add $0,$0,$0
    x"6482", -- sw $1,2($1)
    x"1141", -- sub $4,$4,$2
    x"049A", -- sll $1,$1,1
    x"0000", -- add $0,$0,$0
    x"0000", -- add $0,$0,$0
    x"8604", -- beq $1,$4,4
    x"0000", -- add $0,$0,$0
    x"0000", -- add $0,$0,$0
    x"0000", -- add $0,$0,$0
    x"E014", -- j 20
    x"0000", -- add $0,$0,$0
    x"6085", -- sw $1,5($0)
    others => x"0000"
);


begin

process(clk)
begin
    if rising_edge(clk) then
        if rst='1' then 
            q<=x"0000";
        elsif en='1' then 
            q<=d;
        end if;
    end if;
end process;
pc<=q+1;
next_instr<=pc;
m1<=pc when PCSrc='0' else BranchAddress; 
d<=jumpAddress when jump='1' else m1;
instr<=mem_rom(conv_integer(q(3 downto 0))); 
            
end Behavioral;
