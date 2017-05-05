[Mesh]
  type = FileMesh
  file = Plate_Hole_rectang.msh
  boundary_name = 'bottom top inside outside'
  boundary_id = '109 110 112 111'
  displacements = 'disp_x disp_y'
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  porepressure = porepressure
  block = 0
[]

[MeshModifiers]
  [./Top]
    type = AddExtraNodeset
    new_boundary = 101
    coord = '0 0.18'
  [../]
  [./Bottom]
    type = AddExtraNodeset
    new_boundary = 102
    coord = '0 -0.18'
  [../]
  [./Left]
    type = AddExtraNodeset
    new_boundary = 103
    coord = '-0.2 0'
  [../]
  [./Right]
    type = AddExtraNodeset
    new_boundary = 104
    coord = '0.2 0'
  [../]
[]

[Variables]
  active = 'temperature disp_y disp_x porepressure damage'
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
    block = 0
  [../]
  [./porepressure]
    scaling = 1E9 # Notice the scaling, to make porepressure's kernels roughly of same magnitude as disp's kernels
  [../]
  [./damage]
  [../]
  [./temperature]
  [../]
[]

[AuxVariables]
  [./stress_r_r]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_theta_theta]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_r_theta]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_r_r]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_theta_theta]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_r_theta]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mech_dissip]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mean_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./mises_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Functions]
  active = 'outer_pressure_vertical timestep_function inner_pressure_fct outer_pressure_horizontal'
  [./temp_ic]
    type = ParsedFunction
    value = 'sqrt(x*x+y*y)/0.9 - 1/9' # -sqrt(x*x+y*y)/0.9 + 10/9
  [../]
  [./inner_pressure_fct]
    type = ParsedFunction
    value = 1e-3+4e-2*t # 1e-3+4e-2*t
  [../]
  [./timestep_function]
    # max(1e-7,min(1e1, dt*max(0.2,1-5*(T-T_old-0.2))))
    # 
    # max(1e-7,min(1e-2, dt*max(0.1,0.1-5*(T-T_old-0.2))))
    # 
    # if(T>3.5, 1e-5, max(1e-7,min(1e-2, dt*max(0.2,1-5*(T-T_old-0.2)))))
    # if(t>0.0169, 1e-7, if(t>0.0168, 2e-6, max(1e-7,min(1e-2, dt*max(0.2, 1-5*(T-T_old-0.2))))))
    type = ParsedFunction
    value = 2e-4 # if(t<0.07, 2e-3, 5e-4)
  [../]
  [./outer_pressure_vertical]
    type = ParsedFunction
    value = 1.5e-3
  [../]
  [./outer_pressure_horizontal]
    type = ParsedFunction
    value = 1e-3
  [../]
[]

[Kernels]
  active = 'mech_dissip damage_dt Thermal_press dt_temp dp_dt mass_diff'
  [./dp_dt]
    type = TimeDerivative
    variable = porepressure
  [../]
  [./mass_diff]
    type = RedbackMassDiffusion
    variable = porepressure
  [../]
  [./poromech]
    type = RedbackPoromechanics
    variable = porepressure
    block = '0 1'
  [../]
  [./damage_dt]
    type = TimeDerivative
    variable = damage
  [../]
  [./damage_kernel]
    type = RedbackDamage
    variable = damage
  [../]
  [./dt_temp]
    type = TimeDerivative
    variable = temperature
  [../]
  [./diff_temp]
    type = RedbackThermalDiffusion
    variable = temperature
    time_factor = 1e-5
  [../]
  [./mech_dissip]
    type = RedbackMechDissip
    variable = temperature
  [../]
  [./Thermal_press]
    type = RedbackThermalPressurization
    variable = porepressure
    temperature = temperature
  [../]
[]

[AuxKernels]
  [./plastic_strain_r_r]
    type = RedbackPolarTensorMaterialAux
    variable = strain_r_r
    rank_two_tensor = plastic_strain
    index_j = 0
    index_i = 0
  [../]
  [./plastic_strain_r_theta]
    type = RedbackPolarTensorMaterialAux
    variable = strain_r_theta
    rank_two_tensor = plastic_strain
    index_j = 1
    index_i = 0
  [../]
  [./plastic_strain_theta_theta]
    type = RedbackPolarTensorMaterialAux
    variable = strain_theta_theta
    rank_two_tensor = plastic_strain
    index_j = 1
    index_i = 1
  [../]
  [./stress_r_r]
    type = RedbackPolarTensorMaterialAux
    variable = stress_r_r
    rank_two_tensor = stress
    index_j = 0
    index_i = 0
  [../]
  [./stress_r_theta]
    type = RedbackPolarTensorMaterialAux
    variable = stress_r_theta
    rank_two_tensor = stress
    index_j = 1
    index_i = 0
  [../]
  [./stress_theta_theta]
    type = RedbackPolarTensorMaterialAux
    variable = stress_theta_theta
    rank_two_tensor = stress
    index_j = 1
    index_i = 1
  [../]
  [./mech_dissip]
    type = MaterialRealAux
    variable = mech_dissip
    property = mechanical_dissipation_mech
  [../]
  [./mean_stress]
    type = MaterialRealAux
    variable = mean_stress
    property = mean_stress
  [../]
  [./mises_stress]
    type = MaterialRealAux
    variable = mises_stress
    property = mises_stress
  [../]
[]

[BCs]
  [./Pressure]
    [./press_inner]
      function = inner_pressure_fct
      boundary = 0
      disp_y = disp_y
      disp_x = disp_x
    [../]
    [./press_outer_horizontal]
      function = outer_pressure_horizontal
      boundary = 1
      disp_y = disp_y
      disp_x = disp_x
    [../]
    [./press_outer_vertical]
      function = outer_pressure_vertical
      boundary = 2
      disp_y = disp_y
      disp_x = disp_x
    [../]
  [../]
  [./confine_x]
    type = PresetBC
    variable = disp_x
    boundary = '101 102'
    value = 0
  [../]
  [./confine_y]
    type = PresetBC
    variable = disp_y
    boundary = '103 104'
    value = 0
  [../]
[]

[Materials]
  [./no_mech]
    type = RedbackMaterial
    solid_compressibility = 1000
    gr = 5e3
    disp_y = disp_y
    disp_x = disp_x
    pore_pres = porepressure
    pressurization_coefficient = 5e-4
    ar = 10
    total_porosity = 0.1
    temperature = temperature
    phi0 = 0.1
    is_mechanics_on = true
    fluid_thermal_expansion = 1e-1
    inverse_lewis_number_tilde = porepressure
  [../]
  [./plastic_material]
    type = RedbackMechMaterialDP
    disp_y = disp_y
    disp_x = disp_x
    pore_pres = porepressure
    damage = damage
    yield_stress = '0 0.001 0.1 0.0008' # 0 0.006 1 0.006
    damage_coefficient = 3e3
    damage_method = BrittleDamage
    poisson_ratio = 0.25
    youngs_modulus = 100
    temperature = temperature
  [../]
[]

[Postprocessors]
  active = 'Num_elements disp_hole_x avg_dissip max_r_theta new_timestep old_timestep max_temp'
  [./max_temp]
    type = NodalMaxValue
    variable = temperature
  [../]
  [./new_timestep]
    type = FunctionValuePostprocessor
    function = timestep_function
  [../]
  [./max_temp_old]
    type = NodalMaxValue
    variable = temperature
    execute_on = timestep_begin
  [../]
  [./old_timestep]
    type = TimestepSize
    execute_on = timestep_begin
  [../]
  [./max_r_theta]
    type = ElementExtremeValue
    variable = strain_r_theta
  [../]
  [./nli]
    type = NumLinearIterations
  [../]
  [./nnli]
    type = NumNonlinearIterations
  [../]
  [./avg_dissip]
    type = ElementAverageValue
    variable = mech_dissip
  [../]
  [./disp_hole_x]
    type = PointValue
    variable = disp_x
    point = '0.1 0 0'
  [../]
  [./Num_elements]
    type = NumElems
  [../]
[]

[Preconditioning]
  [./andy]
    type = SMP
    full = true
    solve_type = NEWTON
    petsc_options = '-snes_monitor   -snes_linesearch_monitor   -ksp_monitor'
    petsc_options_iname = '-ksp_type -pc_type  -snes_atol -snes_rtol -snes_max_it -ksp_max_it -ksp_atol -sub_pc_type -sub_pc_factor_shift_type'
    petsc_options_value = 'gmres        asm        1E-10          1E-5        200                500                  1e-8        lu                      NONZERO'
    line_search = basic
  [../]
[]

[Executioner]
  # [./TimeStepper]
  # type = PostprocessorDT
  # postprocessor = dt
  # dt = 0.003
  # [../]
  type = Transient
  l_max_its = 100
  end_time = 1.0 # 0.2
  dt = 1e-3 # 1e-5
  l_tol = 1e-5 # 1e-05
  [./TimeStepper]
    type = PostprocessorDT
    postprocessor = new_timestep
  [../]
[]

[Outputs]
  exodus = true
  execute_on = 'timestep_end initial'
  file_base = Quarter_thickER_J2_anisotr_1
[]

[ICs]
  active = 'random_temp_IC'
  [./random_temp_IC]
    variable = temperature
    type = RandomIC
    seed = 40
  [../]
  [./random_dmg_IC]
    variable = damage
    type = RandomIC
    max = 0.001
  [../]
[]

[RedbackMechAction]
  [./mechanics]
    temp = temperature
    pore_pres = porepressure
    disp_y = disp_y
    disp_x = disp_x
  [../]
[]

