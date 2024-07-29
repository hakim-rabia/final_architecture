library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

signal en,reset,wen: STD_LOGIC;
signal output:STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal instruction,next_instruction:std_logic_vector(15 downto 0);

signal regdst,extop,alusrc,branch,memwrite,memtoreg,regwrite,sa,jump,brne: std_logic;
signal aluop: std_logic_vector(1 downto 0);
signal extimm,rd1,rd2,wd:std_logic_vector(15 downto 0);
signal func:std_logic_vector(2 downto 0);

signal alures,branchAddr,jumpAddr,memdata,aluresout:std_logic_vector(15 downto 0);
signal zero,pcsrc:std_logic;

signal wa:std_logic_vector(2 downto 0);
--IF_ID
signal Instruction_IF_ID,PC_1_IF_ID:std_logic_vector(15 downto 0);
--ID_EX
signal rt,rd,rwa,rt_ID_EX,rd_ID_EX,func_ID_EX:std_logic_vector(2 downto 0);
signal AluOp_ID_EX:std_logic_vector(1 downto 0);
signal RegDst_ID_EX,Branch_ID_EX,BrNE_ID_EX,RegWr_ID_EX,sa_ID_EX,ExtOp_ID_EX,ALUSrc_ID_EX,MemWrite_ID_EX,MemtoReg_ID_EX:std_logic;
signal RD1_ID_EX,RD2_ID_EX,Ext_imm_ID_EX,PC_1_ID_EX:std_logic_vector(15 downto 0);
--EX_MEM
signal Branch_EX_MEM,BrNE_EX_MEM,RegWr_EX_MEM,zero_EX_MEM,MemWrite_EX_MEM,MemtoReg_EX_MEM: std_logic;
signal BranchAddress_EX_MEM,ALURes_EX_MEM,RD2_EX_MEM:std_logic_vector(15 downto 0);
signal rd_EX_MEM:std_logic_vector(2 downto 0);
--MEM_WB
signal ALUResOut_MEM_WB,MemData_MEM_WB:std_logic_vector(15 downto 0);
signal RegWr_MEM_WB,MemtoReg_MEM_WB:std_logic;
signal rd_MEM_WB:std_logic_vector(2 downto 0);

component MPG 
port ( input: in std_logic;
        clk:in std_logic;
       enable: out std_logic
      );
end component;

component SSD
port( clk:in STD_LOGIC;
      digit0,digit1,digit2,digit3: in STD_LOGIC_VECTOR(3 downto 0);
      an : out STD_LOGIC_VECTOR (3 downto 0);
      cat : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component IFetch
port(jump: in std_logic;
     jumpAddress: in std_logic_vector (15 downto 0);
     PCSrc: in std_logic;
     BranchAddress: in std_logic_vector (15 downto 0);
     en: in std_logic;
     rst: in std_logic;
     clk: in std_logic;
     instr: out std_logic_vector (15 downto 0);
     next_instr: out std_logic_vector (15 downto 0) );
end component;

component ID
Port ( RegWrite: in std_logic;
       Instr: in std_logic_vector(15 downto 0);
       clk: in std_logic;
       en: in std_logic;
       ExtOp: in std_logic;
       wd: in std_logic_vector(15 downto 0);
       ext_imm: out std_logic_vector(15 downto 0);
       func: out std_logic_vector(2 downto 0);
       sa: out std_logic;
       rd1: out std_logic_vector(15 downto 0);
       rd2: out std_logic_vector(15 downto 0);
       rt: out std_logic_vector(2 downto 0);
       rd: out std_logic_vector(2 downto 0);
       wa: in std_logic_vector(2 downto 0));
end component;

component MainControl 
    Port( Instr : in std_logic_vector(15 downto 0);
          RegDst,ExtOp,ALUSrc,Branch,Jump,MemWrite,MemtoReg,RegWrite,BrNE: out std_logic;
          ALUOp:out std_logic_vector(1 downto 0));
end component;

component EX
    Port(RD1: in std_logic_vector(15 downto 0);
     RD2: in std_logic_vector(15 downto 0);
     AluSrc: in std_logic;
     Ext_Imm: in std_logic_vector(15 downto 0);
     sa: in std_logic;
     func: in std_logic_vector(2 downto 0);
     AluOp: in std_logic_vector(1 downto 0);
     next_addr: in std_logic_vector(15 downto 0);
     zero: out std_logic;
     AluRes:out std_logic_vector(15 downto 0);
     branchAddress: out std_logic_vector(15 downto 0);
     RegDst:in std_logic;
     rt:in std_logic_vector(2 downto 0);
     rd:in std_logic_vector(2 downto 0);
     rWA:out std_logic_vector(2 downto 0));
end component;

component MEM is
    Port(MemWrite: in std_logic;
         AluResIn: in std_logic_vector(15 downto 0);
         RD2: in std_logic_vector(15 downto 0);
         clk: in std_logic;
         en: in std_logic;
         AluResOut: out std_logic_vector(15 downto 0);
         MemData: out std_logic_vector(15 downto 0));
end component;

begin

process(sw(7 downto 5),instruction,next_instruction,rd1_id_ex,rd2_id_ex,ext_imm_id_ex,alures,memdata,wd)
begin
    case sw(7 downto 5) is
        when "000" => output <= instruction;
        when "001" => output <= next_instruction;
        when "010" => output <= rd1_id_ex;
        when "011" => output <= rd2_id_ex;
        when "100" => output <= ext_imm_id_ex;
        when "101" => output <= alures;
        when "110" => output <= memdata;
        when "111" => output <= wd;
        when others => output <= (others => '0');
    end case;

end process;

led(10 downto 0)<=aluop&RegDst_ID_EX&extop&alusrc_id_ex&branch_ex_mem&jump&memwrite_ex_mem&memtoreg_mem_wb&regwr_mem_wb&brne_ex_mem;

pcsrc<=(BrNE_EX_MEM and not(zero_EX_MEM)) or(zero_EX_MEM and Branch_EX_MEM);
jumpAddr<=PC_1_IF_ID(15 downto 13)&Instruction_IF_ID(12 downto 0);
wd<=ALUResOut_MEM_WB when MemtoReg_MEM_WB='0' else MemData_MEM_WB;
--wa<=rd_MEM_WB;

InstrFetch: IFetch port map(jump=>jump,jumpAddress=>jumpAddr,PCSrc=>pcsrc,branchAddress=>BranchAddress_EX_MEM,en=>en,rst=>reset,clk=>clk,instr=>instruction,next_instr=>next_instruction);

--IF_ID
process(clk)
begin
    if(rising_edge(clk)) then
       if(en='1') then
            Instruction_IF_ID<=instruction;
            PC_1_IF_ID<=next_instruction;
       end if;
    end if;
end process;

UC: MainControl port map(Instr=>Instruction_IF_ID,RegDst=>regdst,ExtOp=>extop,ALUSrc=>alusrc,Branch=>branch,Jump=>jump,MemWrite=>memwrite,MemtoReg=>memtoreg,RegWrite=>regwrite,BrNE=>brne,ALUOp=>aluop);

InstrDecode: ID port map(RegWrite=>RegWr_MEM_WB,Instr=>Instruction_IF_ID,clk=>clk,en=>en,ExtOp=>extop,wd=>wd,ext_imm=>extimm,func=>func,sa=>sa,rd1=>rd1,rd2=>rd2,rt=>rt,rd=>rd,wa=>rd_MEM_WB);

--ID_EX
process(clk)
begin
    if(rising_edge(clk)) then
        if(en='1') then
            RegDst_ID_EX<=regdst;
            Branch_ID_EX<=branch;
            RegWr_ID_EX<=regwrite;
            BrNE_ID_EX<=brne;
            RD1_ID_EX<=rd1;
            RD2_ID_EX<=rd2;
            Ext_imm_ID_EX<=extimm;
            func_ID_EX<=func;
            sa_ID_EX<=sa;
            rd_ID_EX<=rd;
            rt_ID_EX<=rt;
            ExtOp_ID_EX<=extop;
            AluSrc_ID_EX<=alusrc;
            MemWrite_ID_EX<=memwrite;
            MemtoReg_ID_EX<=memtoreg;
            AluOp_ID_EX<=aluop;
            PC_1_ID_EX<=PC_1_IF_ID;
        end if;
    end if;
end process;

EX1: EX port map(RD1=>RD1_ID_EX,RD2=>RD2_ID_EX,AluSrc=>AluSrc_ID_EX,Ext_Imm=>Ext_imm_ID_EX,sa=>sa_ID_EX,func=>func_ID_EX,AluOp=>AluOp_ID_EX,next_addr=>PC_1_ID_EX,zero=>zero,AluRes=>alures,branchAddress=>branchAddr,RegDst=>RegDst_ID_EX,rt=>rt_ID_EX,rd=>rd_ID_EX,rWA=>rwa);


--EX_MEM
process(clk)
begin
    if(rising_edge(clk)) then
       if(en='1') then
            Branch_EX_MEM<=Branch_ID_EX;
            RegWr_EX_MEM<=RegWr_ID_EX;
            zero_EX_MEM<=zero;
            BranchAddress_EX_MEM<=branchAddr;
            ALURes_EX_MEM<=alures;
            rd_EX_MEM<=rwa;
            RD2_EX_MEM<=RD2_ID_EX;
            BrNE_EX_MEM<=BrNE_ID_EX;
            MemWrite_EX_MEM<=MemWrite_ID_EX;
            MemtoReg_EX_MEM<=MemtoReg_ID_EX;
        end if;
    end if;
end process;

MEM1: MEM port map(MemWrite=>MemWrite_EX_MEM,AluResIn=>ALURes_EX_MEM,RD2=>RD2_EX_MEM,clk=>clk,en=>en,AluResOut=>aluresout,MemData=>memdata);

--MEM_WB
process(clk)
begin
    if(rising_edge(clk) ) then
        if(en='1') then
            RegWr_MEM_WB<=RegWr_EX_MEM;
            ALUResOut_MEM_WB<=aluresout;
            MemData_MEM_WB<=memdata;
            rd_MEM_WB<=rd_EX_MEM;
            MemtoReg_MEM_WB<=MemtoReg_EX_MEM;
        end if;
    end if;
end process;
              
monoimpulse:MPG port map(input=>btn(0),clk=>clk, enable=>en);
monoimpulseR:MPG port map(input=>btn(1),clk=>clk, enable=>reset);

display:SSD port map(clk=>clk,digit0=>output(3 downto 0),digit1=>output(7 downto 4),digit2=>output(11 downto 8), digit3=>output(15 downto 12),an=>an,cat=>cat);

end Behavioral;
