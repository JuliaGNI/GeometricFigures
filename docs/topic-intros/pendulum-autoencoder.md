These figures accompany the paper *Symplectic autoencoders for model reduction of Hamiltonian
systems* by B. Brantner and M. Kraus ([arXiv:2312.10004](https://arxiv.org/abs/2312.10004)): they
study a symplectic autoencoder trained on the pendulum and what its latent space does at the
separatrix.

!!! info "Re-training regenerates these figures"
    Several figures draw measurements on the trained weights or on the training set. After the
    symplectic autoencoder is re-trained, or the training set changes, they must be regenerated
    from the new network and then resynced here; the build of this package does not recompute
    them.

    - From the weights, in a generated block: `two-charts` (panel (ii)), `branch-invariants`
      (which also has hand-written values), `upper-branch`, `threshold-split-paper` and
      `threshold-split-sep` (the measured point), `fold-current` and `fold-separatrix`.
    - From the weights, values set by hand: `atlas-vs-chart` (panel (b)), `obstruction-cases`
      (the circle ratio).
    - From the training set only: `covered-half`, `rotating-cap`, `atlas-vs-chart` (panel (a)),
      `threshold-actions-paper`, `threshold-actions-sep` and `threshold-map`; the excluded
      triangle of `threshold-split-paper` and `threshold-split-sep`.

    The other figures of this page are analytic or schematic, and a re-training does not touch
    them.
