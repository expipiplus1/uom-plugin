{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RoleAnnotations #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module Data.UnitsOfMeasure
    ( Quantity(unQuantity) -- N.B. MkQuantity not exported!
    , zero
    , mk
    , unit
    , (%)
    , (+:)
    , (-:)
    , (*:)
    , (/:)
    , negate'
    , sqrt'
    , MkUnit
    , module Data.UnitsOfMeasure.Internal
    ) where

import GHC.Prim (Proxy#, proxy#)
import GHC.TypeLits

import Data.UnitsOfMeasure.Internal

type role Quantity representational nominal
newtype Quantity a (u :: Unit) = MkQuantity { unQuantity :: a }
  deriving (Eq, Ord, Show)

zero :: Num a => Quantity a u
zero = MkQuantity 0

mk :: a -> Quantity a One
mk = MkQuantity

unit :: a -> Proxy# u -> Quantity a u
unit x _ = MkQuantity x

(%) :: a -> Proxy# u -> Quantity a u
(%) = unit

(+:) :: Num a => Quantity a u -> Quantity a u -> Quantity a u
MkQuantity x +: MkQuantity y = MkQuantity (x + y)

(-:) :: Num a => Quantity a u -> Quantity a u -> Quantity a u
MkQuantity x -: MkQuantity y = MkQuantity (x - y)

(*:) :: Num a => Quantity a u -> Quantity a v -> Quantity a (u *: v)
MkQuantity x *: MkQuantity y = MkQuantity (x * y)

(/:) :: Fractional a => Quantity a u -> Quantity a v -> Quantity a (u /: v)
MkQuantity x /: MkQuantity y = MkQuantity (x / y)

infixl 6 +:, -:

sqrt' :: Floating a => Quantity a (u *: u) -> Quantity a u
sqrt' (MkQuantity x) = MkQuantity (sqrt x)

negate' :: Num a => Quantity a u -> Quantity a u
negate' (MkQuantity x) = MkQuantity (negate x)

instance (Num a, u ~ One) => Num (Quantity a u) where
  MkQuantity x + MkQuantity y = MkQuantity (x * y)
  MkQuantity x - MkQuantity y = MkQuantity (x - y)
  MkQuantity x * MkQuantity y = MkQuantity (x * y)
  abs    (MkQuantity x) = MkQuantity (abs x)
  signum (MkQuantity x) = MkQuantity (signum x)
  fromInteger = MkQuantity . fromInteger

instance (Fractional a, u ~ One) => Fractional (Quantity a u) where
  fromRational = MkQuantity . fromRational
  MkQuantity x / MkQuantity y = MkQuantity (x / y)


type family MkUnit (s :: Symbol) :: Unit
