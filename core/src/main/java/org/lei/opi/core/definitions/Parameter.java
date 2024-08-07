/*
 * A decorator that describes elements that can be incoming
 * as JSON strings on a Communicator. 
 * Used to define communication protocol in conjunction with 
 * @ReturnMsg decorator.
 */
package org.lei.opi.core.definitions;

import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target(value = ElementType.METHOD)
@Documented
@Repeatable(Parameters.class)
public @interface Parameter {
  String name();
  Class<?> className() default String.class;   // Seems this is either String, Double or a user defined Enum class
  String desc();
  boolean isList() default false;
  boolean isListList() default false; // for list of lists, as list of RGB color values
  boolean optional() default false;
  double min() default -1e10;
  double max() default 1e10;
  String defaultValue() default "\"?\"";   // JSON format. This is present even for non-optional params to give an example for rgen
}