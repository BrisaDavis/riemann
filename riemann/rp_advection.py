#!/usr/bin/env python
# encoding: utf-8
r"""
Simple advection Riemann solvers

Basic advection Riemann solvers of the form (1d)

.. math::
    q_t + A q_x = 0.
    
:Authors:
    Kyle T. Mandli (2008-2-20): Initial version
"""
# ============================================================================
#      Copyright (C) 2008 Kyle T. Mandli <mandli@amath.washington.edu>
#
#  Distributed under the terms of the Berkeley Software Distribution (BSD) 
#  license
#                     http://www.opensource.org/licenses/
# ============================================================================

# Riemann solver constants
meqn = 1
mwaves = 1

import numpy as np

def rp_advection_1d(q_l,q_r,aux_l,aux_r,aux_global):
    r"""Basic 1d advection riemann solver
    
    *aux_global* should contain -
     - *u* - (float) Determines advection speed
    
    See :ref:`pyclaw_rp` for more details.
    
    :Version: 1.0 (2008-2-20)
    """
    
    # Number of Riemann problems we are solving
    nrp = q_l.shape[1]

    # Return values
    wave = np.empty( (meqn, mwaves, nrp) )
    s = np.empty( (mwaves, nrp) )
    amdq = np.zeros( (meqn, nrp) )
    apdq = np.zeros( (meqn, nrp) )
 
    wave[0,0,:] = q_r[0,:] - q_l[0,:]
    s[0,:] = aux_global['u']
    if aux_global['u'] > 0:
        apdq[0,:] = s[0,:] * wave[0,0,:]
    else:
        amdq[0,:] = s[0,:] * wave[0,0,:]

    return wave, s, amdq, apdq
