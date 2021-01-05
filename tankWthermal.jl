"""
tankWthermal calculates boil-off rate of LH2

Inputs:

NOTE: Everything is in SI units.
-Thermal conductivity array k (W/(m*K)) comprising of k value for each MLI layer
-hconvgas (W/m2*K)  is convective coefficient of insulating purged gas (e.g. N2)
-hconvair (W/m2*K) is convective coefficient of ambient air
-Thickness array t (m) corresponds to thickness value of each layer in MLI
-h_LH2 ((W/m2*K) corresponds to LH2 convective coefficient
-Tfuel (K) is fuel temperature
-Tair (K) is ambient temperature
-r_tank (m) is tank outer radius
-pi is value of pi
-h_e (J/kg) is heat of vaporization of liquid hydrogen (from Hydrogen tank design paper)
-r_gas is inner radius of gas-purged chamber (m)


Outputs:
- m_boiloff (kg) is the boiloff LH2 mass for given mission
"""
function tankWthermal(gee, rhoFuel, deltap,
                      Rfuse, dRfuse,
                      xshell1, xshell2, v_cruise, hconvgas, h_LH2, Tfuel, Tair, r_tank,
                      h_e, t, r_gas, k, hconvair, time_flight)

#--- effective pressure-vessel length
      lshell = xshell2 - xshell1  #pressure vessel length, can be based on tank volume required to store LH2
      N = size(t) #Number of layers in MLI
      thickness = sum(t) #total thickness of MLI

#--- Heat flux and resistances

      deltaT = Tair - Tfuel  #Overall temperature drop between ambient and LH2
      Rair = 1 / (hconvair * 2 * pi * r_tank * lshell)  #thermal resistance of ambient air
      r_inner = r_tank - thickness  #inner radius of tank
      Rgas = 1 / (hconvgas * 2 * pi * (r_inner + r_gas) * lshell)  #thermal resistance of purged gas
      R_LH2 = 1 / (h_LH2 * 2 * pi * r_inner * lshell)  #thermal resistance of LH2

      rang = [1, 2, 3] #This needs to be fixed, should be something like 1:1:N but didn't work. Checking julia format for array
      R_mli = zeros(N)  #size of MLI resistance array (Based on number of layers)
      for n in rang
            R_mli[n] = log((r_inner  + t[n])/ (r_inner)) / (2 * pi * lshell * k[n]) #Resistance of each MLI layer
            r_inner = r_inner + t[n]  #Inner layer w.r.t the nth MLI layer being evaluated
      end

      R_mli = sum(R_mli)  #Total thermal resistance of MLI
      Req = R_mli + Rair + Rgas + R_LH2  #Total equivalent resistance of thermal circuit

      q = deltaT / Req  #Heat flux from ambient to LH2
      m_boiloff = q * time_flight / h_e  #Boil-off mass equals the heat flux divided by heat of vaporization

return  m_boiloff
end
