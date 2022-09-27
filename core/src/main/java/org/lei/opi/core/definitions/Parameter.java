package org.lei.opi.core.definitions;

import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target(value = ElementType.METHOD)
@Documented
@Repeatable(Parameters.class)
public @interface Parameter {
  String name();
  Class<?> className() default String.class;
  String desc();
  boolean isList() default false;
  boolean isListList() default false; // for list of lists, as list of RGB color values
  boolean optional() default false;
  double min() default -1e10;
  double max() default 1e10;
  String defaultValue() default "?";   // maybe only used for generating R @example code...
}