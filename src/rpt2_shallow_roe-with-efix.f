c
c
c     =====================================================
      subroutine rpt2(ixy,maxm,meqn,mwaves,mbc,mx,
     &                ql,qr,aux1,aux2,aux3,
     &                ilr,asdq,bmasdq,bpasdq)
c     =====================================================
      implicit double precision (a-h,o-z)
c
c     # Riemann solver in the transverse direction for the shallow water
c     equations .
c     # Split asdq (= A^* \Delta q, where * = + or -)
c     # into down-going flux difference bmasdq (= B^- A^* \Delta q)
c     #    and up-going flux difference bpasdq (= B^+ A^* \Delta q)
c
c     # Uses Roe averages and other quantities which were
c     # computed in rpn2sh and stored in the common block comroe.
c
      dimension     ql(meqn, 1-mbc:maxm+mbc)
      dimension     qr(meqn, 1-mbc:maxm+mbc)
      dimension   asdq(meqn, 1-mbc:maxm+mbc)
      dimension bmasdq(meqn, 1-mbc:maxm+mbc)
      dimension bpasdq(meqn, 1-mbc:maxm+mbc)
      double precision g
c
c      common /cparam/  g    !# gravitational parameter 
      dimension waveb(3,3),sb(3)
c      parameter (maxm2 = 603)  !# assumes at most 600x600 grid with mbc=3
      dimension u(-2:603)
      dimension v(-2:603)
      dimension a(-2:603)
      dimension hl(-2:603)
      dimension hr(-2:603)
      dimension h(-2:603)
c
      if (-2.gt.1-mbc .or. 603 .lt. maxm+mbc) then
        write(6,*) 'need to increase maxm2 in rpB'
        stop
      endif
c


      if (ixy.eq.1) then
        mu = 2
        mv = 3
      else
        mu = 3
         mv = 2
      endif

      g=1.d0


       do 50 i = 2-mbc, mx+mbc
         h(i) = (qr(1,i-1)+ql(1,i))*0.50d0
         hsqrtl = dsqrt(qr(1,i-1))
         hsqrtr = dsqrt(ql(1,i))
         hsq2 = hsqrtl + hsqrtr
         u(i) = (qr(mu,i-1)/hsqrtl + ql(mu,i)/hsqrtr) / hsq2
         v(i) = (qr(mv,i-1)/hsqrtl + ql(mv,i)/hsqrtr) / hsq2
         a(i) =  dsqrt(g*h(i))
   50    continue


        do 20 i = 2-mbc, mx+mbc
           a1 = (0.50d0/a(i))*((v(i)+a(i))*asdq(1,i)-asdq(mv,i))
           a2 = asdq(mu,i) - u(i)*asdq(1,i)
           a3 = (0.50d0/a(i))*(-(v(i)-a(i))*asdq(1,i)+asdq(mv,i))
c
            waveb(1,1) = a1
            waveb(1,mu) = a1*u(i)
            waveb(1,mv) = a1*(v(i)-a(i))
            sb(1) = v(i) - a(i)
c
            waveb(2,1) = 0.0d0
            waveb(2,mu) = a2
            waveb(2,mv) = 0.0d0
            sb(2) = v(i)
c
            waveb(3,1) = a3
            waveb(3,mu) = a3*u(i)
            waveb(3,mv) = a3*(v(i)+a(i))
            sb(3) = v(i) + a(i)
c
c           # compute the flux differences bmasdq and bpasdq
c
            do 10 m=1,meqn
               bmasdq(m,i) = 0.d0
               bpasdq(m,i) = 0.d0
               do 10 mw=1,mwaves
                  bmasdq(m,i) = bmasdq(m,i)
     &                        + dmin1(sb(mw), 0.d0) * waveb(mw,m)
                  bpasdq(m,i) = bpasdq(m,i)
     &                        + dmax1(sb(mw), 0.d0) * waveb(mw,m)
   10             continue
c
   20          continue
c
      return
      end
