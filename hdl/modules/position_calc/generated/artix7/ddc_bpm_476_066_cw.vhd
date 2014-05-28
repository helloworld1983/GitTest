
-------------------------------------------------------------------
-- System Generator version 13.4 VHDL source file.
--
-- Copyright(C) 2011 by Xilinx, Inc.  All rights reserved.  This
-- text/file contains proprietary, confidential information of Xilinx,
-- Inc., is distributed under license from Xilinx, Inc., and may be used,
-- copied and/or disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc.  Xilinx hereby grants you a license to use
-- this text/file solely for design, simulation, implementation and
-- creation of design files limited to Xilinx devices or technologies.
-- Use with non-Xilinx devices or technologies is expressly prohibited
-- and immediately terminates your license unless covered by a separate
-- agreement.
--
-- Xilinx is providing this design, code, or information "as is" solely
-- for use in developing programs and solutions for Xilinx devices.  By
-- providing this design, code, or information as one possible
-- implementation of this feature, application or standard, Xilinx is
-- making no representation that this implementation is free from any
-- claims of infringement.  You are responsible for obtaining any rights
-- you may require for your implementation.  Xilinx expressly disclaims
-- any warranty whatsoever with respect to the adequacy of the
-- implementation, including but not limited to warranties of
-- merchantability or fitness for a particular purpose.
--
-- Xilinx products are not intended for use in life support appliances,
-- devices, or systems.  Use in such applications is expressly prohibited.
--
-- Any modifications that are made to the source code are done at the user's
-- sole risk and will be unsupported.
--
-- This copyright and support notice must be retained as part of this
-- text at all times.  (c) Copyright 1995-2011 Xilinx, Inc.  All rights
-- reserved.
-------------------------------------------------------------------

-------------------------------------------------------------------
-- System Generator version 13.4 VHDL source file.
--
-- Copyright(C) 2011 by Xilinx, Inc.  All rights reserved.  This
-- text/file contains proprietary, confidential information of Xilinx,
-- Inc., is distributed under license from Xilinx, Inc., and may be used,
-- copied and/or disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc.  Xilinx hereby grants you a license to use
-- this text/file solely for design, simulation, implementation and
-- creation of design files limited to Xilinx devices or technologies.
-- Use with non-Xilinx devices or technologies is expressly prohibited
-- and immediately terminates your license unless covered by a separate
-- agreement.
--
-- Xilinx is providing this design, code, or information "as is" solely
-- for use in developing programs and solutions for Xilinx devices.  By
-- providing this design, code, or information as one possible
-- implementation of this feature, application or standard, Xilinx is
-- making no representation that this implementation is free from any
-- claims of infringement.  You are responsible for obtaining any rights
-- you may require for your implementation.  Xilinx expressly disclaims
-- any warranty whatsoever with respect to the adequacy of the
-- implementation, including but not limited to warranties of
-- merchantability or fitness for a particular purpose.
--
-- Xilinx products are not intended for use in life support appliances,
-- devices, or systems.  Use in such applications is expressly prohibited.
--
-- Any modifications that are made to the source code are done at the user's
-- sole risk and will be unsupported.
--
-- This copyright and support notice must be retained as part of this
-- text at all times.  (c) Copyright 1995-2011 Xilinx, Inc.  All rights
-- reserved.
-------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.conv_pkg.all;
-- synopsys translate_off
library unisim;
use unisim.vcomponents.all;
-- synopsys translate_on
entity xlclockdriver is
  generic (
    period: integer := 2;
    log_2_period: integer := 0;
    pipeline_regs: integer := 5;
    use_bufg: integer := 0
  );
  port (
    sysclk: in std_logic;
    sysclr: in std_logic;
    sysce: in std_logic;
    clk: out std_logic;
    clr: out std_logic;
    ce: out std_logic;
    ce_logic: out std_logic
  );
end xlclockdriver;
architecture behavior of xlclockdriver is
  component bufg
    port (
      i: in std_logic;
      o: out std_logic
    );
  end component;
  component synth_reg_w_init
    generic (
      width: integer;
      init_index: integer;
      init_value: bit_vector;
      latency: integer
    );
    port (
      i: in std_logic_vector(width - 1 downto 0);
      ce: in std_logic;
      clr: in std_logic;
      clk: in std_logic;
      o: out std_logic_vector(width - 1 downto 0)
    );
  end component;
  function size_of_uint(inp: integer; power_of_2: boolean)
    return integer
  is
    constant inp_vec: std_logic_vector(31 downto 0) :=
      integer_to_std_logic_vector(inp,32, xlUnsigned);
    variable result: integer;
  begin
    result := 32;
    for i in 0 to 31 loop
      if inp_vec(i) = '1' then
        result := i;
      end if;
    end loop;
    if power_of_2 then
      return result;
    else
      return result+1;
    end if;
  end;
  function is_power_of_2(inp: std_logic_vector)
    return boolean
  is
    constant width: integer := inp'length;
    variable vec: std_logic_vector(width - 1 downto 0);
    variable single_bit_set: boolean;
    variable more_than_one_bit_set: boolean;
    variable result: boolean;
  begin
    vec := inp;
    single_bit_set := false;
    more_than_one_bit_set := false;
    -- synopsys translate_off
    if (is_XorU(vec)) then
      return false;
    end if;
     -- synopsys translate_on
    if width > 0 then
      for i in 0 to width - 1 loop
        if vec(i) = '1' then
          if single_bit_set then
            more_than_one_bit_set := true;
          end if;
          single_bit_set := true;
        end if;
      end loop;
    end if;
    if (single_bit_set and not(more_than_one_bit_set)) then
      result := true;
    else
      result := false;
    end if;
    return result;
  end;
  function ce_reg_init_val(index, period : integer)
    return integer
  is
     variable result: integer;
   begin
      result := 0;
      if ((index mod period) = 0) then
          result := 1;
      end if;
      return result;
  end;
  function remaining_pipe_regs(num_pipeline_regs, period : integer)
    return integer
  is
     variable factor, result: integer;
  begin
      factor := (num_pipeline_regs / period);
      result := num_pipeline_regs - (period * factor) + 1;
      return result;
  end;

  function sg_min(L, R: INTEGER) return INTEGER is
  begin
      if L < R then
            return L;
      else
            return R;
      end if;
  end;
  constant max_pipeline_regs : integer := 8;
  constant pipe_regs : integer := 5;
  constant num_pipeline_regs : integer := sg_min(pipeline_regs, max_pipeline_regs);
  constant rem_pipeline_regs : integer := remaining_pipe_regs(num_pipeline_regs,period);
  constant period_floor: integer := max(2, period);
  constant power_of_2_counter: boolean :=
    is_power_of_2(integer_to_std_logic_vector(period_floor,32, xlUnsigned));
  constant cnt_width: integer :=
    size_of_uint(period_floor, power_of_2_counter);
  constant clk_for_ce_pulse_minus1: std_logic_vector(cnt_width - 1 downto 0) :=
    integer_to_std_logic_vector((period_floor - 2),cnt_width, xlUnsigned);
  constant clk_for_ce_pulse_minus2: std_logic_vector(cnt_width - 1 downto 0) :=
    integer_to_std_logic_vector(max(0,period - 3),cnt_width, xlUnsigned);
  constant clk_for_ce_pulse_minus_regs: std_logic_vector(cnt_width - 1 downto 0) :=
    integer_to_std_logic_vector(max(0,period - rem_pipeline_regs),cnt_width, xlUnsigned);
  signal clk_num: unsigned(cnt_width - 1 downto 0) := (others => '0');
  signal ce_vec : std_logic_vector(num_pipeline_regs downto 0);
  attribute MAX_FANOUT : string;
  attribute MAX_FANOUT of ce_vec:signal is "REDUCE";
  signal ce_vec_logic : std_logic_vector(num_pipeline_regs downto 0);
  attribute MAX_FANOUT of ce_vec_logic:signal is "REDUCE";
  signal internal_ce: std_logic_vector(0 downto 0);
  signal internal_ce_logic: std_logic_vector(0 downto 0);
  signal cnt_clr, cnt_clr_dly: std_logic_vector (0 downto 0);
begin
  clk <= sysclk;
  clr <= sysclr;
  cntr_gen: process(sysclk)
  begin
    if sysclk'event and sysclk = '1'  then
      if (sysce = '1') then
        if ((cnt_clr_dly(0) = '1') or (sysclr = '1')) then
          clk_num <= (others => '0');
        else
          clk_num <= clk_num + 1;
        end if;
    end if;
    end if;
  end process;
  clr_gen: process(clk_num, sysclr)
  begin
    if power_of_2_counter then
      cnt_clr(0) <= sysclr;
    else
      if (unsigned_to_std_logic_vector(clk_num) = clk_for_ce_pulse_minus1
          or sysclr = '1') then
        cnt_clr(0) <= '1';
      else
        cnt_clr(0) <= '0';
      end if;
    end if;
  end process;
  clr_reg: synth_reg_w_init
    generic map (
      width => 1,
      init_index => 0,
      init_value => b"0000",
      latency => 1
    )
    port map (
      i => cnt_clr,
      ce => sysce,
      clr => sysclr,
      clk => sysclk,
      o => cnt_clr_dly
    );
  pipelined_ce : if period > 1 generate
      ce_gen: process(clk_num)
      begin
          if unsigned_to_std_logic_vector(clk_num) = clk_for_ce_pulse_minus_regs then
              ce_vec(num_pipeline_regs) <= '1';
          else
              ce_vec(num_pipeline_regs) <= '0';
          end if;
      end process;
      ce_pipeline: for index in num_pipeline_regs downto 1 generate
          ce_reg : synth_reg_w_init
              generic map (
                  width => 1,
                  init_index => ce_reg_init_val(index, period),
                  init_value => b"0000",
                  latency => 1
                  )
              port map (
                  i => ce_vec(index downto index),
                  ce => sysce,
                  clr => sysclr,
                  clk => sysclk,
                  o => ce_vec(index-1 downto index-1)
                  );
      end generate;
      internal_ce <= ce_vec(0 downto 0);
  end generate;
  pipelined_ce_logic: if period > 1 generate
      ce_gen_logic: process(clk_num)
      begin
          if unsigned_to_std_logic_vector(clk_num) = clk_for_ce_pulse_minus_regs then
              ce_vec_logic(num_pipeline_regs) <= '1';
          else
              ce_vec_logic(num_pipeline_regs) <= '0';
          end if;
      end process;
      ce_logic_pipeline: for index in num_pipeline_regs downto 1 generate
          ce_logic_reg : synth_reg_w_init
              generic map (
                  width => 1,
                  init_index => ce_reg_init_val(index, period),
                  init_value => b"0000",
                  latency => 1
                  )
              port map (
                  i => ce_vec_logic(index downto index),
                  ce => sysce,
                  clr => sysclr,
                  clk => sysclk,
                  o => ce_vec_logic(index-1 downto index-1)
                  );
      end generate;
      internal_ce_logic <= ce_vec_logic(0 downto 0);
  end generate;
  use_bufg_true: if period > 1 and use_bufg = 1 generate
    ce_bufg_inst: bufg
      port map (
        i => internal_ce(0),
        o => ce
      );
    ce_bufg_inst_logic: bufg
      port map (
        i => internal_ce_logic(0),
        o => ce_logic
      );
  end generate;
  use_bufg_false: if period > 1 and (use_bufg = 0) generate
    ce <= internal_ce(0);
    ce_logic <= internal_ce_logic(0);
  end generate;
  generate_system_clk: if period = 1 generate
    ce <= sysce;
    ce_logic <= sysce;
  end generate;
end architecture behavior;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

entity default_clock_driver is
  port (
    sysce: in std_logic; 
    sysce_clr: in std_logic; 
    sysclk: in std_logic; 
    ce_1: out std_logic; 
    ce_10000: out std_logic; 
    ce_1120: out std_logic; 
    ce_1400000: out std_logic; 
    ce_2: out std_logic; 
    ce_2240: out std_logic; 
    ce_22400000: out std_logic; 
    ce_224000000: out std_logic; 
    ce_2500: out std_logic; 
    ce_2800000: out std_logic; 
    ce_35: out std_logic; 
    ce_4480: out std_logic; 
    ce_44800000: out std_logic; 
    ce_5000: out std_logic; 
    ce_560: out std_logic; 
    ce_5600000: out std_logic; 
    ce_56000000: out std_logic; 
    ce_70: out std_logic; 
    ce_logic_1: out std_logic; 
    ce_logic_1400000: out std_logic; 
    ce_logic_2240: out std_logic; 
    ce_logic_22400000: out std_logic; 
    ce_logic_2800000: out std_logic; 
    ce_logic_560: out std_logic; 
    ce_logic_5600000: out std_logic; 
    ce_logic_70: out std_logic; 
    clk_1: out std_logic; 
    clk_10000: out std_logic; 
    clk_1120: out std_logic; 
    clk_1400000: out std_logic; 
    clk_2: out std_logic; 
    clk_2240: out std_logic; 
    clk_22400000: out std_logic; 
    clk_224000000: out std_logic; 
    clk_2500: out std_logic; 
    clk_2800000: out std_logic; 
    clk_35: out std_logic; 
    clk_4480: out std_logic; 
    clk_44800000: out std_logic; 
    clk_5000: out std_logic; 
    clk_560: out std_logic; 
    clk_5600000: out std_logic; 
    clk_56000000: out std_logic; 
    clk_70: out std_logic
  );
end default_clock_driver;

architecture structural of default_clock_driver is
  attribute syn_noprune: boolean;
  attribute syn_noprune of structural : architecture is true;
  attribute optimize_primitives: boolean;
  attribute optimize_primitives of structural : architecture is false;
  attribute dont_touch: boolean;
  attribute dont_touch of structural : architecture is true;

  signal sysce_clr_x0: std_logic;
  signal sysce_x0: std_logic;
  signal sysclk_x0: std_logic;
  signal xlclockdriver_10000_ce: std_logic;
  signal xlclockdriver_10000_clk: std_logic;
  signal xlclockdriver_1120_ce: std_logic;
  signal xlclockdriver_1120_clk: std_logic;
  signal xlclockdriver_1400000_ce: std_logic;
  signal xlclockdriver_1400000_ce_logic: std_logic;
  signal xlclockdriver_1400000_clk: std_logic;
  signal xlclockdriver_1_ce: std_logic;
  signal xlclockdriver_1_ce_logic: std_logic;
  signal xlclockdriver_1_clk: std_logic;
  signal xlclockdriver_224000000_ce: std_logic;
  signal xlclockdriver_224000000_clk: std_logic;
  signal xlclockdriver_22400000_ce: std_logic;
  signal xlclockdriver_22400000_ce_logic: std_logic;
  signal xlclockdriver_22400000_clk: std_logic;
  signal xlclockdriver_2240_ce: std_logic;
  signal xlclockdriver_2240_ce_logic: std_logic;
  signal xlclockdriver_2240_clk: std_logic;
  signal xlclockdriver_2500_ce: std_logic;
  signal xlclockdriver_2500_clk: std_logic;
  signal xlclockdriver_2800000_ce: std_logic;
  signal xlclockdriver_2800000_ce_logic: std_logic;
  signal xlclockdriver_2800000_clk: std_logic;
  signal xlclockdriver_2_ce: std_logic;
  signal xlclockdriver_2_clk: std_logic;
  signal xlclockdriver_35_ce: std_logic;
  signal xlclockdriver_35_clk: std_logic;
  signal xlclockdriver_44800000_ce: std_logic;
  signal xlclockdriver_44800000_clk: std_logic;
  signal xlclockdriver_4480_ce: std_logic;
  signal xlclockdriver_4480_clk: std_logic;
  signal xlclockdriver_5000_ce: std_logic;
  signal xlclockdriver_5000_clk: std_logic;
  signal xlclockdriver_56000000_ce: std_logic;
  signal xlclockdriver_56000000_clk: std_logic;
  signal xlclockdriver_5600000_ce: std_logic;
  signal xlclockdriver_5600000_ce_logic: std_logic;
  signal xlclockdriver_5600000_clk: std_logic;
  signal xlclockdriver_560_ce: std_logic;
  signal xlclockdriver_560_ce_logic: std_logic;
  signal xlclockdriver_560_clk: std_logic;
  signal xlclockdriver_70_ce: std_logic;
  signal xlclockdriver_70_ce_logic: std_logic;
  signal xlclockdriver_70_clk: std_logic;

begin
  sysce_x0 <= sysce;
  sysce_clr_x0 <= sysce_clr;
  sysclk_x0 <= sysclk;
  ce_1 <= xlclockdriver_1_ce;
  ce_10000 <= xlclockdriver_10000_ce;
  ce_1120 <= xlclockdriver_1120_ce;
  ce_1400000 <= xlclockdriver_1400000_ce;
  ce_2 <= xlclockdriver_2_ce;
  ce_2240 <= xlclockdriver_2240_ce;
  ce_22400000 <= xlclockdriver_22400000_ce;
  ce_224000000 <= xlclockdriver_224000000_ce;
  ce_2500 <= xlclockdriver_2500_ce;
  ce_2800000 <= xlclockdriver_2800000_ce;
  ce_35 <= xlclockdriver_35_ce;
  ce_4480 <= xlclockdriver_4480_ce;
  ce_44800000 <= xlclockdriver_44800000_ce;
  ce_5000 <= xlclockdriver_5000_ce;
  ce_560 <= xlclockdriver_560_ce;
  ce_5600000 <= xlclockdriver_5600000_ce;
  ce_56000000 <= xlclockdriver_56000000_ce;
  ce_70 <= xlclockdriver_70_ce;
  ce_logic_1 <= xlclockdriver_1_ce_logic;
  ce_logic_1400000 <= xlclockdriver_1400000_ce_logic;
  ce_logic_2240 <= xlclockdriver_2240_ce_logic;
  ce_logic_22400000 <= xlclockdriver_22400000_ce_logic;
  ce_logic_2800000 <= xlclockdriver_2800000_ce_logic;
  ce_logic_560 <= xlclockdriver_560_ce_logic;
  ce_logic_5600000 <= xlclockdriver_5600000_ce_logic;
  ce_logic_70 <= xlclockdriver_70_ce_logic;
  clk_1 <= xlclockdriver_1_clk;
  clk_10000 <= xlclockdriver_10000_clk;
  clk_1120 <= xlclockdriver_1120_clk;
  clk_1400000 <= xlclockdriver_1400000_clk;
  clk_2 <= xlclockdriver_2_clk;
  clk_2240 <= xlclockdriver_2240_clk;
  clk_22400000 <= xlclockdriver_22400000_clk;
  clk_224000000 <= xlclockdriver_224000000_clk;
  clk_2500 <= xlclockdriver_2500_clk;
  clk_2800000 <= xlclockdriver_2800000_clk;
  clk_35 <= xlclockdriver_35_clk;
  clk_4480 <= xlclockdriver_4480_clk;
  clk_44800000 <= xlclockdriver_44800000_clk;
  clk_5000 <= xlclockdriver_5000_clk;
  clk_560 <= xlclockdriver_560_clk;
  clk_5600000 <= xlclockdriver_5600000_clk;
  clk_56000000 <= xlclockdriver_56000000_clk;
  clk_70 <= xlclockdriver_70_clk;

  xlclockdriver_1: entity work.xlclockdriver
    generic map (
      log_2_period => 1,
      period => 1,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_1_ce,
      ce_logic => xlclockdriver_1_ce_logic,
      clk => xlclockdriver_1_clk
    );

  xlclockdriver_10000: entity work.xlclockdriver
    generic map (
      log_2_period => 14,
      period => 10000,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_10000_ce,
      clk => xlclockdriver_10000_clk
    );

  xlclockdriver_1120: entity work.xlclockdriver
    generic map (
      log_2_period => 11,
      period => 1120,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_1120_ce,
      clk => xlclockdriver_1120_clk
    );

  xlclockdriver_1400000: entity work.xlclockdriver
    generic map (
      log_2_period => 21,
      period => 1400000,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_1400000_ce,
      ce_logic => xlclockdriver_1400000_ce_logic,
      clk => xlclockdriver_1400000_clk
    );

  xlclockdriver_2: entity work.xlclockdriver
    generic map (
      log_2_period => 2,
      period => 2,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_2_ce,
      clk => xlclockdriver_2_clk
    );

  xlclockdriver_2240: entity work.xlclockdriver
    generic map (
      log_2_period => 12,
      period => 2240,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_2240_ce,
      ce_logic => xlclockdriver_2240_ce_logic,
      clk => xlclockdriver_2240_clk
    );

  xlclockdriver_22400000: entity work.xlclockdriver
    generic map (
      log_2_period => 25,
      period => 22400000,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_22400000_ce,
      ce_logic => xlclockdriver_22400000_ce_logic,
      clk => xlclockdriver_22400000_clk
    );

  xlclockdriver_224000000: entity work.xlclockdriver
    generic map (
      log_2_period => 28,
      period => 224000000,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_224000000_ce,
      clk => xlclockdriver_224000000_clk
    );

  xlclockdriver_2500: entity work.xlclockdriver
    generic map (
      log_2_period => 12,
      period => 2500,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_2500_ce,
      clk => xlclockdriver_2500_clk
    );

  xlclockdriver_2800000: entity work.xlclockdriver
    generic map (
      log_2_period => 22,
      period => 2800000,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_2800000_ce,
      ce_logic => xlclockdriver_2800000_ce_logic,
      clk => xlclockdriver_2800000_clk
    );

  xlclockdriver_35: entity work.xlclockdriver
    generic map (
      log_2_period => 6,
      period => 35,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_35_ce,
      clk => xlclockdriver_35_clk
    );

  xlclockdriver_4480: entity work.xlclockdriver
    generic map (
      log_2_period => 13,
      period => 4480,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_4480_ce,
      clk => xlclockdriver_4480_clk
    );

  xlclockdriver_44800000: entity work.xlclockdriver
    generic map (
      log_2_period => 26,
      period => 44800000,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_44800000_ce,
      clk => xlclockdriver_44800000_clk
    );

  xlclockdriver_5000: entity work.xlclockdriver
    generic map (
      log_2_period => 13,
      period => 5000,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_5000_ce,
      clk => xlclockdriver_5000_clk
    );

  xlclockdriver_560: entity work.xlclockdriver
    generic map (
      log_2_period => 10,
      period => 560,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_560_ce,
      ce_logic => xlclockdriver_560_ce_logic,
      clk => xlclockdriver_560_clk
    );

  xlclockdriver_5600000: entity work.xlclockdriver
    generic map (
      log_2_period => 23,
      period => 5600000,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_5600000_ce,
      ce_logic => xlclockdriver_5600000_ce_logic,
      clk => xlclockdriver_5600000_clk
    );

  xlclockdriver_56000000: entity work.xlclockdriver
    generic map (
      log_2_period => 26,
      period => 56000000,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_56000000_ce,
      clk => xlclockdriver_56000000_clk
    );

  xlclockdriver_70: entity work.xlclockdriver
    generic map (
      log_2_period => 7,
      period => 70,
      use_bufg => 0
    )
    port map (
      sysce => sysce_x0,
      sysclk => sysclk_x0,
      sysclr => sysce_clr_x0,
      ce => xlclockdriver_70_ce,
      ce_logic => xlclockdriver_70_ce_logic,
      clk => xlclockdriver_70_clk
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

entity ddc_bpm_476_066_cw is
  port (
    adc_ch0_i: in std_logic_vector(15 downto 0); 
    adc_ch1_i: in std_logic_vector(15 downto 0); 
    adc_ch2_i: in std_logic_vector(15 downto 0); 
    adc_ch3_i: in std_logic_vector(15 downto 0); 
    ce: in std_logic := '1'; 
    ce_clr: in std_logic := '1'; 
    clk: in std_logic; -- clock period = 4.44116091946435 ns (225.16635135135124 Mhz)
    dds_config_valid_ch0_i: in std_logic; 
    dds_config_valid_ch1_i: in std_logic; 
    dds_config_valid_ch2_i: in std_logic; 
    dds_config_valid_ch3_i: in std_logic; 
    dds_pinc_ch0_i: in std_logic_vector(29 downto 0); 
    dds_pinc_ch1_i: in std_logic_vector(29 downto 0); 
    dds_pinc_ch2_i: in std_logic_vector(29 downto 0); 
    dds_pinc_ch3_i: in std_logic_vector(29 downto 0); 
    dds_poff_ch0_i: in std_logic_vector(29 downto 0); 
    dds_poff_ch1_i: in std_logic_vector(29 downto 0); 
    dds_poff_ch2_i: in std_logic_vector(29 downto 0); 
    dds_poff_ch3_i: in std_logic_vector(29 downto 0); 
    del_sig_div_fofb_thres_i: in std_logic_vector(25 downto 0); 
    del_sig_div_monit_thres_i: in std_logic_vector(25 downto 0); 
    del_sig_div_tbt_thres_i: in std_logic_vector(25 downto 0); 
    ksum_i: in std_logic_vector(24 downto 0); 
    kx_i: in std_logic_vector(24 downto 0); 
    ky_i: in std_logic_vector(24 downto 0); 
    adc_ch0_dbg_data_o: out std_logic_vector(15 downto 0); 
    adc_ch1_dbg_data_o: out std_logic_vector(15 downto 0); 
    adc_ch2_dbg_data_o: out std_logic_vector(15 downto 0); 
    adc_ch3_dbg_data_o: out std_logic_vector(15 downto 0); 
    bpf_ch0_o: out std_logic_vector(23 downto 0); 
    bpf_ch1_o: out std_logic_vector(23 downto 0); 
    bpf_ch2_o: out std_logic_vector(23 downto 0); 
    bpf_ch3_o: out std_logic_vector(23 downto 0); 
    cic_fofb_q_01_missing_o: out std_logic; 
    cic_fofb_q_23_missing_o: out std_logic; 
    fofb_amp_ch0_o: out std_logic_vector(23 downto 0); 
    fofb_amp_ch1_o: out std_logic_vector(23 downto 0); 
    fofb_amp_ch2_o: out std_logic_vector(23 downto 0); 
    fofb_amp_ch3_o: out std_logic_vector(23 downto 0); 
    fofb_decim_ch0_i_o: out std_logic_vector(23 downto 0); 
    fofb_decim_ch0_q_o: out std_logic_vector(23 downto 0); 
    fofb_decim_ch1_i_o: out std_logic_vector(23 downto 0); 
    fofb_decim_ch1_q_o: out std_logic_vector(23 downto 0); 
    fofb_decim_ch2_i_o: out std_logic_vector(23 downto 0); 
    fofb_decim_ch2_q_o: out std_logic_vector(23 downto 0); 
    fofb_decim_ch3_i_o: out std_logic_vector(23 downto 0); 
    fofb_decim_ch3_q_o: out std_logic_vector(23 downto 0); 
    fofb_pha_ch0_o: out std_logic_vector(23 downto 0); 
    fofb_pha_ch1_o: out std_logic_vector(23 downto 0); 
    fofb_pha_ch2_o: out std_logic_vector(23 downto 0); 
    fofb_pha_ch3_o: out std_logic_vector(23 downto 0); 
    mix_ch0_i_o: out std_logic_vector(23 downto 0); 
    mix_ch0_q_o: out std_logic_vector(23 downto 0); 
    mix_ch1_i_o: out std_logic_vector(23 downto 0); 
    mix_ch1_q_o: out std_logic_vector(23 downto 0); 
    mix_ch2_i_o: out std_logic_vector(23 downto 0); 
    mix_ch2_q_o: out std_logic_vector(23 downto 0); 
    mix_ch3_i_o: out std_logic_vector(23 downto 0); 
    mix_ch3_q_o: out std_logic_vector(23 downto 0); 
    monit_amp_ch0_o: out std_logic_vector(23 downto 0); 
    monit_amp_ch1_o: out std_logic_vector(23 downto 0); 
    monit_amp_ch2_o: out std_logic_vector(23 downto 0); 
    monit_amp_ch3_o: out std_logic_vector(23 downto 0); 
    monit_cfir_incorrect_o: out std_logic; 
    monit_cic_unexpected_o: out std_logic; 
    monit_pfir_incorrect_o: out std_logic; 
    monit_pos_1_incorrect_o: out std_logic; 
    q_fofb_o: out std_logic_vector(25 downto 0); 
    q_fofb_valid_o: out std_logic; 
    q_monit_1_o: out std_logic_vector(25 downto 0); 
    q_monit_1_valid_o: out std_logic; 
    q_monit_o: out std_logic_vector(25 downto 0); 
    q_monit_valid_o: out std_logic; 
    q_tbt_o: out std_logic_vector(25 downto 0); 
    q_tbt_valid_o: out std_logic; 
    sum_fofb_o: out std_logic_vector(25 downto 0); 
    sum_fofb_valid_o: out std_logic; 
    sum_monit_1_o: out std_logic_vector(25 downto 0); 
    sum_monit_1_valid_o: out std_logic; 
    sum_monit_o: out std_logic_vector(25 downto 0); 
    sum_monit_valid_o: out std_logic; 
    sum_tbt_o: out std_logic_vector(25 downto 0); 
    sum_tbt_valid_o: out std_logic; 
    tbt_amp_ch0_o: out std_logic_vector(23 downto 0); 
    tbt_amp_ch1_o: out std_logic_vector(23 downto 0); 
    tbt_amp_ch2_o: out std_logic_vector(23 downto 0); 
    tbt_amp_ch3_o: out std_logic_vector(23 downto 0); 
    tbt_decim_ch01_incorrect_o: out std_logic; 
    tbt_decim_ch0_i_o: out std_logic_vector(23 downto 0); 
    tbt_decim_ch0_q_o: out std_logic_vector(23 downto 0); 
    tbt_decim_ch1_i_o: out std_logic_vector(23 downto 0); 
    tbt_decim_ch1_q_o: out std_logic_vector(23 downto 0); 
    tbt_decim_ch23_incorrect_o: out std_logic; 
    tbt_decim_ch2_i_o: out std_logic_vector(23 downto 0); 
    tbt_decim_ch2_q_o: out std_logic_vector(23 downto 0); 
    tbt_decim_ch3_i_o: out std_logic_vector(23 downto 0); 
    tbt_decim_ch3_q_o: out std_logic_vector(23 downto 0); 
    tbt_pha_ch0_o: out std_logic_vector(23 downto 0); 
    tbt_pha_ch1_o: out std_logic_vector(23 downto 0); 
    tbt_pha_ch2_o: out std_logic_vector(23 downto 0); 
    tbt_pha_ch3_o: out std_logic_vector(23 downto 0); 
    x_fofb_o: out std_logic_vector(25 downto 0); 
    x_fofb_valid_o: out std_logic; 
    x_monit_1_o: out std_logic_vector(25 downto 0); 
    x_monit_1_valid_o: out std_logic; 
    x_monit_o: out std_logic_vector(25 downto 0); 
    x_monit_valid_o: out std_logic; 
    x_tbt_o: out std_logic_vector(25 downto 0); 
    x_tbt_valid_o: out std_logic; 
    y_fofb_o: out std_logic_vector(25 downto 0); 
    y_fofb_valid_o: out std_logic; 
    y_monit_1_o: out std_logic_vector(25 downto 0); 
    y_monit_1_valid_o: out std_logic; 
    y_monit_o: out std_logic_vector(25 downto 0); 
    y_monit_valid_o: out std_logic; 
    y_tbt_o: out std_logic_vector(25 downto 0); 
    y_tbt_valid_o: out std_logic
  );
end ddc_bpm_476_066_cw;

architecture structural of ddc_bpm_476_066_cw is
  component xlpersistentdff
    port (
      clk: in std_logic; 
      d: in std_logic; 
      q: out std_logic
    );
  end component;
  attribute syn_black_box: boolean;
  attribute syn_black_box of xlpersistentdff: component is true;
  attribute box_type: string;
  attribute box_type of xlpersistentdff: component is "black_box";
  attribute syn_noprune: boolean;
  attribute optimize_primitives: boolean;
  attribute dont_touch: boolean;
  attribute syn_noprune of xlpersistentdff: component is true;
  attribute optimize_primitives of xlpersistentdff: component is false;
  attribute dont_touch of xlpersistentdff: component is true;

  signal adc_ch0_dbg_data_o_net: std_logic_vector(15 downto 0);
  signal adc_ch0_i_net: std_logic_vector(15 downto 0);
  signal adc_ch1_dbg_data_o_net: std_logic_vector(15 downto 0);
  signal adc_ch1_i_net: std_logic_vector(15 downto 0);
  signal adc_ch2_dbg_data_o_net: std_logic_vector(15 downto 0);
  signal adc_ch2_i_net: std_logic_vector(15 downto 0);
  signal adc_ch3_dbg_data_o_net: std_logic_vector(15 downto 0);
  signal adc_ch3_i_net: std_logic_vector(15 downto 0);
  signal bpf_ch0_o_net: std_logic_vector(23 downto 0);
  signal bpf_ch1_o_net: std_logic_vector(23 downto 0);
  signal bpf_ch2_o_net: std_logic_vector(23 downto 0);
  signal bpf_ch3_o_net: std_logic_vector(23 downto 0);
  signal ce_10000_sg_x2: std_logic;
  attribute MAX_FANOUT: string;
  attribute MAX_FANOUT of ce_10000_sg_x2: signal is "REDUCE";
  signal ce_1120_sg_x32: std_logic;
  attribute MAX_FANOUT of ce_1120_sg_x32: signal is "REDUCE";
  signal ce_1400000_sg_x3: std_logic;
  attribute MAX_FANOUT of ce_1400000_sg_x3: signal is "REDUCE";
  signal ce_1_sg_x96: std_logic;
  attribute MAX_FANOUT of ce_1_sg_x96: signal is "REDUCE";
  signal ce_224000000_sg_x7: std_logic;
  attribute MAX_FANOUT of ce_224000000_sg_x7: signal is "REDUCE";
  signal ce_22400000_sg_x28: std_logic;
  attribute MAX_FANOUT of ce_22400000_sg_x28: signal is "REDUCE";
  signal ce_2240_sg_x28: std_logic;
  attribute MAX_FANOUT of ce_2240_sg_x28: signal is "REDUCE";
  signal ce_2500_sg_x3: std_logic;
  attribute MAX_FANOUT of ce_2500_sg_x3: signal is "REDUCE";
  signal ce_2800000_sg_x4: std_logic;
  attribute MAX_FANOUT of ce_2800000_sg_x4: signal is "REDUCE";
  signal ce_2_sg_x38: std_logic;
  attribute MAX_FANOUT of ce_2_sg_x38: signal is "REDUCE";
  signal ce_35_sg_x22: std_logic;
  attribute MAX_FANOUT of ce_35_sg_x22: signal is "REDUCE";
  signal ce_44800000_sg_x2: std_logic;
  attribute MAX_FANOUT of ce_44800000_sg_x2: signal is "REDUCE";
  signal ce_4480_sg_x9: std_logic;
  attribute MAX_FANOUT of ce_4480_sg_x9: signal is "REDUCE";
  signal ce_5000_sg_x9: std_logic;
  attribute MAX_FANOUT of ce_5000_sg_x9: signal is "REDUCE";
  signal ce_56000000_sg_x5: std_logic;
  attribute MAX_FANOUT of ce_56000000_sg_x5: signal is "REDUCE";
  signal ce_5600000_sg_x12: std_logic;
  attribute MAX_FANOUT of ce_5600000_sg_x12: signal is "REDUCE";
  signal ce_560_sg_x3: std_logic;
  attribute MAX_FANOUT of ce_560_sg_x3: signal is "REDUCE";
  signal ce_70_sg_x27: std_logic;
  attribute MAX_FANOUT of ce_70_sg_x27: signal is "REDUCE";
  signal ce_clr_x0: std_logic;
  signal ce_logic_1400000_sg_x2: std_logic;
  signal ce_logic_1_sg_x20: std_logic;
  signal ce_logic_22400000_sg_x1: std_logic;
  signal ce_logic_2240_sg_x1: std_logic;
  signal ce_logic_2800000_sg_x2: std_logic;
  signal ce_logic_5600000_sg_x2: std_logic;
  signal ce_logic_560_sg_x3: std_logic;
  signal ce_logic_70_sg_x1: std_logic;
  signal cic_fofb_q_01_missing_o_net: std_logic;
  signal cic_fofb_q_23_missing_o_net: std_logic;
  signal clkNet: std_logic;
  signal clk_10000_sg_x2: std_logic;
  signal clk_1120_sg_x32: std_logic;
  signal clk_1400000_sg_x3: std_logic;
  signal clk_1_sg_x96: std_logic;
  signal clk_224000000_sg_x7: std_logic;
  signal clk_22400000_sg_x28: std_logic;
  signal clk_2240_sg_x28: std_logic;
  signal clk_2500_sg_x3: std_logic;
  signal clk_2800000_sg_x4: std_logic;
  signal clk_2_sg_x38: std_logic;
  signal clk_35_sg_x22: std_logic;
  signal clk_44800000_sg_x2: std_logic;
  signal clk_4480_sg_x9: std_logic;
  signal clk_5000_sg_x9: std_logic;
  signal clk_56000000_sg_x5: std_logic;
  signal clk_5600000_sg_x12: std_logic;
  signal clk_560_sg_x3: std_logic;
  signal clk_70_sg_x27: std_logic;
  signal dds_config_valid_ch0_i_net: std_logic;
  signal dds_config_valid_ch1_i_net: std_logic;
  signal dds_config_valid_ch2_i_net: std_logic;
  signal dds_config_valid_ch3_i_net: std_logic;
  signal dds_pinc_ch0_i_net: std_logic_vector(29 downto 0);
  signal dds_pinc_ch1_i_net: std_logic_vector(29 downto 0);
  signal dds_pinc_ch2_i_net: std_logic_vector(29 downto 0);
  signal dds_pinc_ch3_i_net: std_logic_vector(29 downto 0);
  signal dds_poff_ch0_i_net: std_logic_vector(29 downto 0);
  signal dds_poff_ch1_i_net: std_logic_vector(29 downto 0);
  signal dds_poff_ch2_i_net: std_logic_vector(29 downto 0);
  signal dds_poff_ch3_i_net: std_logic_vector(29 downto 0);
  signal del_sig_div_fofb_thres_i_net: std_logic_vector(25 downto 0);
  signal del_sig_div_monit_thres_i_net: std_logic_vector(25 downto 0);
  signal del_sig_div_tbt_thres_i_net: std_logic_vector(25 downto 0);
  signal fofb_amp_ch0_o_net: std_logic_vector(23 downto 0);
  signal fofb_amp_ch1_o_net: std_logic_vector(23 downto 0);
  signal fofb_amp_ch2_o_net: std_logic_vector(23 downto 0);
  signal fofb_amp_ch3_o_net: std_logic_vector(23 downto 0);
  signal fofb_decim_ch0_i_o_net: std_logic_vector(23 downto 0);
  signal fofb_decim_ch0_q_o_net: std_logic_vector(23 downto 0);
  signal fofb_decim_ch1_i_o_net: std_logic_vector(23 downto 0);
  signal fofb_decim_ch1_q_o_net: std_logic_vector(23 downto 0);
  signal fofb_decim_ch2_i_o_net: std_logic_vector(23 downto 0);
  signal fofb_decim_ch2_q_o_net: std_logic_vector(23 downto 0);
  signal fofb_decim_ch3_i_o_net: std_logic_vector(23 downto 0);
  signal fofb_decim_ch3_q_o_net: std_logic_vector(23 downto 0);
  signal fofb_pha_ch0_o_net: std_logic_vector(23 downto 0);
  signal fofb_pha_ch1_o_net: std_logic_vector(23 downto 0);
  signal fofb_pha_ch2_o_net: std_logic_vector(23 downto 0);
  signal fofb_pha_ch3_o_net: std_logic_vector(23 downto 0);
  signal ksum_i_net: std_logic_vector(24 downto 0);
  signal kx_i_net: std_logic_vector(24 downto 0);
  signal ky_i_net: std_logic_vector(24 downto 0);
  signal mix_ch0_i_o_net: std_logic_vector(23 downto 0);
  signal mix_ch0_q_o_net: std_logic_vector(23 downto 0);
  signal mix_ch1_i_o_net: std_logic_vector(23 downto 0);
  signal mix_ch1_q_o_net: std_logic_vector(23 downto 0);
  signal mix_ch2_i_o_net: std_logic_vector(23 downto 0);
  signal mix_ch2_q_o_net: std_logic_vector(23 downto 0);
  signal mix_ch3_i_o_net: std_logic_vector(23 downto 0);
  signal mix_ch3_q_o_net: std_logic_vector(23 downto 0);
  signal monit_amp_ch0_o_net: std_logic_vector(23 downto 0);
  signal monit_amp_ch1_o_net: std_logic_vector(23 downto 0);
  signal monit_amp_ch2_o_net: std_logic_vector(23 downto 0);
  signal monit_amp_ch3_o_net: std_logic_vector(23 downto 0);
  signal monit_cfir_incorrect_o_net: std_logic;
  signal monit_cic_unexpected_o_net: std_logic;
  signal monit_pfir_incorrect_o_net: std_logic;
  signal monit_pos_1_incorrect_o_net: std_logic;
  signal persistentdff_inst_q: std_logic;
  attribute syn_keep: boolean;
  attribute syn_keep of persistentdff_inst_q: signal is true;
  attribute keep: boolean;
  attribute keep of persistentdff_inst_q: signal is true;
  attribute preserve_signal: boolean;
  attribute preserve_signal of persistentdff_inst_q: signal is true;
  signal q_fofb_o_net: std_logic_vector(25 downto 0);
  signal q_fofb_valid_o_net: std_logic;
  signal q_monit_1_o_net: std_logic_vector(25 downto 0);
  signal q_monit_1_valid_o_net: std_logic;
  signal q_monit_o_net: std_logic_vector(25 downto 0);
  signal q_monit_valid_o_net: std_logic;
  signal q_tbt_o_net: std_logic_vector(25 downto 0);
  signal q_tbt_valid_o_net: std_logic;
  signal sum_fofb_o_net: std_logic_vector(25 downto 0);
  signal sum_fofb_valid_o_net: std_logic;
  signal sum_monit_1_o_net: std_logic_vector(25 downto 0);
  signal sum_monit_1_valid_o_net: std_logic;
  signal sum_monit_o_net: std_logic_vector(25 downto 0);
  signal sum_monit_valid_o_net: std_logic;
  signal sum_tbt_o_net: std_logic_vector(25 downto 0);
  signal sum_tbt_valid_o_net: std_logic;
  signal tbt_amp_ch0_o_net: std_logic_vector(23 downto 0);
  signal tbt_amp_ch1_o_net: std_logic_vector(23 downto 0);
  signal tbt_amp_ch2_o_net: std_logic_vector(23 downto 0);
  signal tbt_amp_ch3_o_net: std_logic_vector(23 downto 0);
  signal tbt_decim_ch01_incorrect_o_net: std_logic;
  signal tbt_decim_ch0_i_o_net: std_logic_vector(23 downto 0);
  signal tbt_decim_ch0_q_o_net: std_logic_vector(23 downto 0);
  signal tbt_decim_ch1_i_o_net: std_logic_vector(23 downto 0);
  signal tbt_decim_ch1_q_o_net: std_logic_vector(23 downto 0);
  signal tbt_decim_ch23_incorrect_o_net: std_logic;
  signal tbt_decim_ch2_i_o_net: std_logic_vector(23 downto 0);
  signal tbt_decim_ch2_q_o_net: std_logic_vector(23 downto 0);
  signal tbt_decim_ch3_i_o_net: std_logic_vector(23 downto 0);
  signal tbt_decim_ch3_q_o_net: std_logic_vector(23 downto 0);
  signal tbt_pha_ch0_o_net: std_logic_vector(23 downto 0);
  signal tbt_pha_ch1_o_net: std_logic_vector(23 downto 0);
  signal tbt_pha_ch2_o_net: std_logic_vector(23 downto 0);
  signal tbt_pha_ch3_o_net: std_logic_vector(23 downto 0);
  signal x_fofb_o_net: std_logic_vector(25 downto 0);
  signal x_fofb_valid_o_net: std_logic;
  signal x_monit_1_o_net: std_logic_vector(25 downto 0);
  signal x_monit_1_valid_o_net: std_logic;
  signal x_monit_o_net: std_logic_vector(25 downto 0);
  signal x_monit_valid_o_net: std_logic;
  signal x_tbt_o_net: std_logic_vector(25 downto 0);
  signal x_tbt_valid_o_net: std_logic;
  signal y_fofb_o_net: std_logic_vector(25 downto 0);
  signal y_fofb_valid_o_net: std_logic;
  signal y_monit_1_o_net: std_logic_vector(25 downto 0);
  signal y_monit_1_valid_o_net: std_logic;
  signal y_monit_o_net: std_logic_vector(25 downto 0);
  signal y_monit_valid_o_net: std_logic;
  signal y_tbt_o_net: std_logic_vector(25 downto 0);
  signal y_tbt_valid_o_net: std_logic;

begin
  adc_ch0_i_net <= adc_ch0_i;
  adc_ch1_i_net <= adc_ch1_i;
  adc_ch2_i_net <= adc_ch2_i;
  adc_ch3_i_net <= adc_ch3_i;
  ce_clr_x0 <= ce_clr;
  clkNet <= clk;
  dds_config_valid_ch0_i_net <= dds_config_valid_ch0_i;
  dds_config_valid_ch1_i_net <= dds_config_valid_ch1_i;
  dds_config_valid_ch2_i_net <= dds_config_valid_ch2_i;
  dds_config_valid_ch3_i_net <= dds_config_valid_ch3_i;
  dds_pinc_ch0_i_net <= dds_pinc_ch0_i;
  dds_pinc_ch1_i_net <= dds_pinc_ch1_i;
  dds_pinc_ch2_i_net <= dds_pinc_ch2_i;
  dds_pinc_ch3_i_net <= dds_pinc_ch3_i;
  dds_poff_ch0_i_net <= dds_poff_ch0_i;
  dds_poff_ch1_i_net <= dds_poff_ch1_i;
  dds_poff_ch2_i_net <= dds_poff_ch2_i;
  dds_poff_ch3_i_net <= dds_poff_ch3_i;
  del_sig_div_fofb_thres_i_net <= del_sig_div_fofb_thres_i;
  del_sig_div_monit_thres_i_net <= del_sig_div_monit_thres_i;
  del_sig_div_tbt_thres_i_net <= del_sig_div_tbt_thres_i;
  ksum_i_net <= ksum_i;
  kx_i_net <= kx_i;
  ky_i_net <= ky_i;
  adc_ch0_dbg_data_o <= adc_ch0_dbg_data_o_net;
  adc_ch1_dbg_data_o <= adc_ch1_dbg_data_o_net;
  adc_ch2_dbg_data_o <= adc_ch2_dbg_data_o_net;
  adc_ch3_dbg_data_o <= adc_ch3_dbg_data_o_net;
  bpf_ch0_o <= bpf_ch0_o_net;
  bpf_ch1_o <= bpf_ch1_o_net;
  bpf_ch2_o <= bpf_ch2_o_net;
  bpf_ch3_o <= bpf_ch3_o_net;
  cic_fofb_q_01_missing_o <= cic_fofb_q_01_missing_o_net;
  cic_fofb_q_23_missing_o <= cic_fofb_q_23_missing_o_net;
  fofb_amp_ch0_o <= fofb_amp_ch0_o_net;
  fofb_amp_ch1_o <= fofb_amp_ch1_o_net;
  fofb_amp_ch2_o <= fofb_amp_ch2_o_net;
  fofb_amp_ch3_o <= fofb_amp_ch3_o_net;
  fofb_decim_ch0_i_o <= fofb_decim_ch0_i_o_net;
  fofb_decim_ch0_q_o <= fofb_decim_ch0_q_o_net;
  fofb_decim_ch1_i_o <= fofb_decim_ch1_i_o_net;
  fofb_decim_ch1_q_o <= fofb_decim_ch1_q_o_net;
  fofb_decim_ch2_i_o <= fofb_decim_ch2_i_o_net;
  fofb_decim_ch2_q_o <= fofb_decim_ch2_q_o_net;
  fofb_decim_ch3_i_o <= fofb_decim_ch3_i_o_net;
  fofb_decim_ch3_q_o <= fofb_decim_ch3_q_o_net;
  fofb_pha_ch0_o <= fofb_pha_ch0_o_net;
  fofb_pha_ch1_o <= fofb_pha_ch1_o_net;
  fofb_pha_ch2_o <= fofb_pha_ch2_o_net;
  fofb_pha_ch3_o <= fofb_pha_ch3_o_net;
  mix_ch0_i_o <= mix_ch0_i_o_net;
  mix_ch0_q_o <= mix_ch0_q_o_net;
  mix_ch1_i_o <= mix_ch1_i_o_net;
  mix_ch1_q_o <= mix_ch1_q_o_net;
  mix_ch2_i_o <= mix_ch2_i_o_net;
  mix_ch2_q_o <= mix_ch2_q_o_net;
  mix_ch3_i_o <= mix_ch3_i_o_net;
  mix_ch3_q_o <= mix_ch3_q_o_net;
  monit_amp_ch0_o <= monit_amp_ch0_o_net;
  monit_amp_ch1_o <= monit_amp_ch1_o_net;
  monit_amp_ch2_o <= monit_amp_ch2_o_net;
  monit_amp_ch3_o <= monit_amp_ch3_o_net;
  monit_cfir_incorrect_o <= monit_cfir_incorrect_o_net;
  monit_cic_unexpected_o <= monit_cic_unexpected_o_net;
  monit_pfir_incorrect_o <= monit_pfir_incorrect_o_net;
  monit_pos_1_incorrect_o <= monit_pos_1_incorrect_o_net;
  q_fofb_o <= q_fofb_o_net;
  q_fofb_valid_o <= q_fofb_valid_o_net;
  q_monit_1_o <= q_monit_1_o_net;
  q_monit_1_valid_o <= q_monit_1_valid_o_net;
  q_monit_o <= q_monit_o_net;
  q_monit_valid_o <= q_monit_valid_o_net;
  q_tbt_o <= q_tbt_o_net;
  q_tbt_valid_o <= q_tbt_valid_o_net;
  sum_fofb_o <= sum_fofb_o_net;
  sum_fofb_valid_o <= sum_fofb_valid_o_net;
  sum_monit_1_o <= sum_monit_1_o_net;
  sum_monit_1_valid_o <= sum_monit_1_valid_o_net;
  sum_monit_o <= sum_monit_o_net;
  sum_monit_valid_o <= sum_monit_valid_o_net;
  sum_tbt_o <= sum_tbt_o_net;
  sum_tbt_valid_o <= sum_tbt_valid_o_net;
  tbt_amp_ch0_o <= tbt_amp_ch0_o_net;
  tbt_amp_ch1_o <= tbt_amp_ch1_o_net;
  tbt_amp_ch2_o <= tbt_amp_ch2_o_net;
  tbt_amp_ch3_o <= tbt_amp_ch3_o_net;
  tbt_decim_ch01_incorrect_o <= tbt_decim_ch01_incorrect_o_net;
  tbt_decim_ch0_i_o <= tbt_decim_ch0_i_o_net;
  tbt_decim_ch0_q_o <= tbt_decim_ch0_q_o_net;
  tbt_decim_ch1_i_o <= tbt_decim_ch1_i_o_net;
  tbt_decim_ch1_q_o <= tbt_decim_ch1_q_o_net;
  tbt_decim_ch23_incorrect_o <= tbt_decim_ch23_incorrect_o_net;
  tbt_decim_ch2_i_o <= tbt_decim_ch2_i_o_net;
  tbt_decim_ch2_q_o <= tbt_decim_ch2_q_o_net;
  tbt_decim_ch3_i_o <= tbt_decim_ch3_i_o_net;
  tbt_decim_ch3_q_o <= tbt_decim_ch3_q_o_net;
  tbt_pha_ch0_o <= tbt_pha_ch0_o_net;
  tbt_pha_ch1_o <= tbt_pha_ch1_o_net;
  tbt_pha_ch2_o <= tbt_pha_ch2_o_net;
  tbt_pha_ch3_o <= tbt_pha_ch3_o_net;
  x_fofb_o <= x_fofb_o_net;
  x_fofb_valid_o <= x_fofb_valid_o_net;
  x_monit_1_o <= x_monit_1_o_net;
  x_monit_1_valid_o <= x_monit_1_valid_o_net;
  x_monit_o <= x_monit_o_net;
  x_monit_valid_o <= x_monit_valid_o_net;
  x_tbt_o <= x_tbt_o_net;
  x_tbt_valid_o <= x_tbt_valid_o_net;
  y_fofb_o <= y_fofb_o_net;
  y_fofb_valid_o <= y_fofb_valid_o_net;
  y_monit_1_o <= y_monit_1_o_net;
  y_monit_1_valid_o <= y_monit_1_valid_o_net;
  y_monit_o <= y_monit_o_net;
  y_monit_valid_o <= y_monit_valid_o_net;
  y_tbt_o <= y_tbt_o_net;
  y_tbt_valid_o <= y_tbt_valid_o_net;

  ddc_bpm_476_066_x0: entity work.ddc_bpm_476_066
    port map (
      adc_ch0_i => adc_ch0_i_net,
      adc_ch1_i => adc_ch1_i_net,
      adc_ch2_i => adc_ch2_i_net,
      adc_ch3_i => adc_ch3_i_net,
      ce_1 => ce_1_sg_x96,
      ce_10000 => ce_10000_sg_x2,
      ce_1120 => ce_1120_sg_x32,
      ce_1400000 => ce_1400000_sg_x3,
      ce_2 => ce_2_sg_x38,
      ce_2240 => ce_2240_sg_x28,
      ce_22400000 => ce_22400000_sg_x28,
      ce_224000000 => ce_224000000_sg_x7,
      ce_2500 => ce_2500_sg_x3,
      ce_2800000 => ce_2800000_sg_x4,
      ce_35 => ce_35_sg_x22,
      ce_4480 => ce_4480_sg_x9,
      ce_44800000 => ce_44800000_sg_x2,
      ce_5000 => ce_5000_sg_x9,
      ce_560 => ce_560_sg_x3,
      ce_5600000 => ce_5600000_sg_x12,
      ce_56000000 => ce_56000000_sg_x5,
      ce_70 => ce_70_sg_x27,
      ce_logic_1 => ce_logic_1_sg_x20,
      ce_logic_1400000 => ce_logic_1400000_sg_x2,
      ce_logic_2240 => ce_logic_2240_sg_x1,
      ce_logic_22400000 => ce_logic_22400000_sg_x1,
      ce_logic_2800000 => ce_logic_2800000_sg_x2,
      ce_logic_560 => ce_logic_560_sg_x3,
      ce_logic_5600000 => ce_logic_5600000_sg_x2,
      ce_logic_70 => ce_logic_70_sg_x1,
      clk_1 => clk_1_sg_x96,
      clk_10000 => clk_10000_sg_x2,
      clk_1120 => clk_1120_sg_x32,
      clk_1400000 => clk_1400000_sg_x3,
      clk_2 => clk_2_sg_x38,
      clk_2240 => clk_2240_sg_x28,
      clk_22400000 => clk_22400000_sg_x28,
      clk_224000000 => clk_224000000_sg_x7,
      clk_2500 => clk_2500_sg_x3,
      clk_2800000 => clk_2800000_sg_x4,
      clk_35 => clk_35_sg_x22,
      clk_4480 => clk_4480_sg_x9,
      clk_44800000 => clk_44800000_sg_x2,
      clk_5000 => clk_5000_sg_x9,
      clk_560 => clk_560_sg_x3,
      clk_5600000 => clk_5600000_sg_x12,
      clk_56000000 => clk_56000000_sg_x5,
      clk_70 => clk_70_sg_x27,
      dds_config_valid_ch0_i => dds_config_valid_ch0_i_net,
      dds_config_valid_ch1_i => dds_config_valid_ch1_i_net,
      dds_config_valid_ch2_i => dds_config_valid_ch2_i_net,
      dds_config_valid_ch3_i => dds_config_valid_ch3_i_net,
      dds_pinc_ch0_i => dds_pinc_ch0_i_net,
      dds_pinc_ch1_i => dds_pinc_ch1_i_net,
      dds_pinc_ch2_i => dds_pinc_ch2_i_net,
      dds_pinc_ch3_i => dds_pinc_ch3_i_net,
      dds_poff_ch0_i => dds_poff_ch0_i_net,
      dds_poff_ch1_i => dds_poff_ch1_i_net,
      dds_poff_ch2_i => dds_poff_ch2_i_net,
      dds_poff_ch3_i => dds_poff_ch3_i_net,
      del_sig_div_fofb_thres_i => del_sig_div_fofb_thres_i_net,
      del_sig_div_monit_thres_i => del_sig_div_monit_thres_i_net,
      del_sig_div_tbt_thres_i => del_sig_div_tbt_thres_i_net,
      ksum_i => ksum_i_net,
      kx_i => kx_i_net,
      ky_i => ky_i_net,
      adc_ch0_dbg_data_o => adc_ch0_dbg_data_o_net,
      adc_ch1_dbg_data_o => adc_ch1_dbg_data_o_net,
      adc_ch2_dbg_data_o => adc_ch2_dbg_data_o_net,
      adc_ch3_dbg_data_o => adc_ch3_dbg_data_o_net,
      bpf_ch0_o => bpf_ch0_o_net,
      bpf_ch1_o => bpf_ch1_o_net,
      bpf_ch2_o => bpf_ch2_o_net,
      bpf_ch3_o => bpf_ch3_o_net,
      cic_fofb_q_01_missing_o => cic_fofb_q_01_missing_o_net,
      cic_fofb_q_23_missing_o => cic_fofb_q_23_missing_o_net,
      fofb_amp_ch0_o => fofb_amp_ch0_o_net,
      fofb_amp_ch1_o => fofb_amp_ch1_o_net,
      fofb_amp_ch2_o => fofb_amp_ch2_o_net,
      fofb_amp_ch3_o => fofb_amp_ch3_o_net,
      fofb_decim_ch0_i_o => fofb_decim_ch0_i_o_net,
      fofb_decim_ch0_q_o => fofb_decim_ch0_q_o_net,
      fofb_decim_ch1_i_o => fofb_decim_ch1_i_o_net,
      fofb_decim_ch1_q_o => fofb_decim_ch1_q_o_net,
      fofb_decim_ch2_i_o => fofb_decim_ch2_i_o_net,
      fofb_decim_ch2_q_o => fofb_decim_ch2_q_o_net,
      fofb_decim_ch3_i_o => fofb_decim_ch3_i_o_net,
      fofb_decim_ch3_q_o => fofb_decim_ch3_q_o_net,
      fofb_pha_ch0_o => fofb_pha_ch0_o_net,
      fofb_pha_ch1_o => fofb_pha_ch1_o_net,
      fofb_pha_ch2_o => fofb_pha_ch2_o_net,
      fofb_pha_ch3_o => fofb_pha_ch3_o_net,
      mix_ch0_i_o => mix_ch0_i_o_net,
      mix_ch0_q_o => mix_ch0_q_o_net,
      mix_ch1_i_o => mix_ch1_i_o_net,
      mix_ch1_q_o => mix_ch1_q_o_net,
      mix_ch2_i_o => mix_ch2_i_o_net,
      mix_ch2_q_o => mix_ch2_q_o_net,
      mix_ch3_i_o => mix_ch3_i_o_net,
      mix_ch3_q_o => mix_ch3_q_o_net,
      monit_amp_ch0_o => monit_amp_ch0_o_net,
      monit_amp_ch1_o => monit_amp_ch1_o_net,
      monit_amp_ch2_o => monit_amp_ch2_o_net,
      monit_amp_ch3_o => monit_amp_ch3_o_net,
      monit_cfir_incorrect_o => monit_cfir_incorrect_o_net,
      monit_cic_unexpected_o => monit_cic_unexpected_o_net,
      monit_pfir_incorrect_o => monit_pfir_incorrect_o_net,
      monit_pos_1_incorrect_o => monit_pos_1_incorrect_o_net,
      q_fofb_o => q_fofb_o_net,
      q_fofb_valid_o => q_fofb_valid_o_net,
      q_monit_1_o => q_monit_1_o_net,
      q_monit_1_valid_o => q_monit_1_valid_o_net,
      q_monit_o => q_monit_o_net,
      q_monit_valid_o => q_monit_valid_o_net,
      q_tbt_o => q_tbt_o_net,
      q_tbt_valid_o => q_tbt_valid_o_net,
      sum_fofb_o => sum_fofb_o_net,
      sum_fofb_valid_o => sum_fofb_valid_o_net,
      sum_monit_1_o => sum_monit_1_o_net,
      sum_monit_1_valid_o => sum_monit_1_valid_o_net,
      sum_monit_o => sum_monit_o_net,
      sum_monit_valid_o => sum_monit_valid_o_net,
      sum_tbt_o => sum_tbt_o_net,
      sum_tbt_valid_o => sum_tbt_valid_o_net,
      tbt_amp_ch0_o => tbt_amp_ch0_o_net,
      tbt_amp_ch1_o => tbt_amp_ch1_o_net,
      tbt_amp_ch2_o => tbt_amp_ch2_o_net,
      tbt_amp_ch3_o => tbt_amp_ch3_o_net,
      tbt_decim_ch01_incorrect_o => tbt_decim_ch01_incorrect_o_net,
      tbt_decim_ch0_i_o => tbt_decim_ch0_i_o_net,
      tbt_decim_ch0_q_o => tbt_decim_ch0_q_o_net,
      tbt_decim_ch1_i_o => tbt_decim_ch1_i_o_net,
      tbt_decim_ch1_q_o => tbt_decim_ch1_q_o_net,
      tbt_decim_ch23_incorrect_o => tbt_decim_ch23_incorrect_o_net,
      tbt_decim_ch2_i_o => tbt_decim_ch2_i_o_net,
      tbt_decim_ch2_q_o => tbt_decim_ch2_q_o_net,
      tbt_decim_ch3_i_o => tbt_decim_ch3_i_o_net,
      tbt_decim_ch3_q_o => tbt_decim_ch3_q_o_net,
      tbt_pha_ch0_o => tbt_pha_ch0_o_net,
      tbt_pha_ch1_o => tbt_pha_ch1_o_net,
      tbt_pha_ch2_o => tbt_pha_ch2_o_net,
      tbt_pha_ch3_o => tbt_pha_ch3_o_net,
      x_fofb_o => x_fofb_o_net,
      x_fofb_valid_o => x_fofb_valid_o_net,
      x_monit_1_o => x_monit_1_o_net,
      x_monit_1_valid_o => x_monit_1_valid_o_net,
      x_monit_o => x_monit_o_net,
      x_monit_valid_o => x_monit_valid_o_net,
      x_tbt_o => x_tbt_o_net,
      x_tbt_valid_o => x_tbt_valid_o_net,
      y_fofb_o => y_fofb_o_net,
      y_fofb_valid_o => y_fofb_valid_o_net,
      y_monit_1_o => y_monit_1_o_net,
      y_monit_1_valid_o => y_monit_1_valid_o_net,
      y_monit_o => y_monit_o_net,
      y_monit_valid_o => y_monit_valid_o_net,
      y_tbt_o => y_tbt_o_net,
      y_tbt_valid_o => y_tbt_valid_o_net
    );

  default_clock_driver_x0: entity work.default_clock_driver
    port map (
      sysce => '1',
      sysce_clr => ce_clr_x0,
      sysclk => clkNet,
      ce_1 => ce_1_sg_x96,
      ce_10000 => ce_10000_sg_x2,
      ce_1120 => ce_1120_sg_x32,
      ce_1400000 => ce_1400000_sg_x3,
      ce_2 => ce_2_sg_x38,
      ce_2240 => ce_2240_sg_x28,
      ce_22400000 => ce_22400000_sg_x28,
      ce_224000000 => ce_224000000_sg_x7,
      ce_2500 => ce_2500_sg_x3,
      ce_2800000 => ce_2800000_sg_x4,
      ce_35 => ce_35_sg_x22,
      ce_4480 => ce_4480_sg_x9,
      ce_44800000 => ce_44800000_sg_x2,
      ce_5000 => ce_5000_sg_x9,
      ce_560 => ce_560_sg_x3,
      ce_5600000 => ce_5600000_sg_x12,
      ce_56000000 => ce_56000000_sg_x5,
      ce_70 => ce_70_sg_x27,
      ce_logic_1 => ce_logic_1_sg_x20,
      ce_logic_1400000 => ce_logic_1400000_sg_x2,
      ce_logic_2240 => ce_logic_2240_sg_x1,
      ce_logic_22400000 => ce_logic_22400000_sg_x1,
      ce_logic_2800000 => ce_logic_2800000_sg_x2,
      ce_logic_560 => ce_logic_560_sg_x3,
      ce_logic_5600000 => ce_logic_5600000_sg_x2,
      ce_logic_70 => ce_logic_70_sg_x1,
      clk_1 => clk_1_sg_x96,
      clk_10000 => clk_10000_sg_x2,
      clk_1120 => clk_1120_sg_x32,
      clk_1400000 => clk_1400000_sg_x3,
      clk_2 => clk_2_sg_x38,
      clk_2240 => clk_2240_sg_x28,
      clk_22400000 => clk_22400000_sg_x28,
      clk_224000000 => clk_224000000_sg_x7,
      clk_2500 => clk_2500_sg_x3,
      clk_2800000 => clk_2800000_sg_x4,
      clk_35 => clk_35_sg_x22,
      clk_4480 => clk_4480_sg_x9,
      clk_44800000 => clk_44800000_sg_x2,
      clk_5000 => clk_5000_sg_x9,
      clk_560 => clk_560_sg_x3,
      clk_5600000 => clk_5600000_sg_x12,
      clk_56000000 => clk_56000000_sg_x5,
      clk_70 => clk_70_sg_x27
    );

  persistentdff_inst: xlpersistentdff
    port map (
      clk => clkNet,
      d => persistentdff_inst_q,
      q => persistentdff_inst_q
    );

end structural;
