import {
  FluffyInner,
  PurpleInner,
} from "./generated/AppKit.framework/extracted";

export interface SimpleMethodArgument {
  name: string | undefined;
  origin: FluffyInner;
}

export interface SimpleMethod {
  origin: PurpleInner;
  description: string | undefined;
  name: string;
  isStatic: boolean;
  arguments: SimpleMethodArgument[];
}

export interface SimpleClass {
  name: string;
  methods: Record<string, SimpleMethod>;
}
