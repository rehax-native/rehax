import {
  FluffyInner,
  FrameworkInner,
  TentacledInner,
  StickyInner,
  PurpleInner,
  IndigoInner,
  HilariousInner,
} from "../generated/rehax/extracted";

export interface SimpleMethodArgument {
  name: string | undefined;
  origin:
    | FluffyInner
    | TentacledInner
    | StickyInner
    | IndigoInner
    | HilariousInner;
}

export interface SimpleMethod {
  origin:
    | PurpleInner
    | FluffyInner
    | TentacledInner
    | StickyInner
    | IndigoInner;
  description: string | undefined;
  name: string;
  isStatic: boolean;
  arguments: SimpleMethodArgument[];
}

export interface SimpleClass {
  name: string;
  origin:
    | FluffyInner
    | PurpleInner
    | FrameworkInner
    | TentacledInner
    | StickyInner;
  // superClass: string | undefined;
  namespace?: string,
  methods: Record<string, SimpleMethod>;
}
