# GAS Station MySQL Database

**Technologies used:** MySQL, VS Code 

## Overview

A MySQL database that stores information about synthesizer modules. Inspired by [ModularGrid.net](https://modulargrid.net). View [diagram here](./GAS%20Station%20-%20Implementation.png).

## Details

This database project structures, stores, and queries information about modular synthesizer equipment, including individual modules, cases, complete synthesizer systems, and patches. Modular systems are composed of modules which are arranged into racks, which fit inside of a case. One or more cases compose a synthesizer. Once a synthesizer is assembled, users connect inputs to outputs in order to create a patch.

Tables include:
- `module`, with subordinate tables and junctions describing the `module_function`, `manufacturer`, `module_format`, `jack`s, and an associated `power_bus`, if any
- `rack`, with an associated `case`, a junction table `module_rack` connecting each `module` to a `rack`, and an associated `power_bus`, if any
- `case`, with an associated `synth`, important specs stored in `case_model`, one or more associated `power_bus`, if any, and one or more associated `patch`, if any.
- `synth`, a collection of one or more `case` instances that can store any `patch` that involves more than one `case`.

Sample views include:
- all modules in a synth, case, or rack
- all module functions within a synth, case, or rack
- all connections in a patch
- total power draw of all modules within a case

Completed for INFO 638 Database Development and Design. Name inspired by [Gear Acquisition Syndrome](https://www.guitarworld.com/features/gear-acquisition-syndrome).