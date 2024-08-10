use std::ops::Add;

use crate::parser::{ParseTree, Transition, TransitionStep};
use inkwell::builder::{Builder, BuilderError};
use inkwell::context::Context;
use inkwell::targets::TargetTriple;
use inkwell::module::Module;
use inkwell::types::{PointerType, BasicMetadataTypeEnum};
use inkwell::values::BasicMetadataValueEnum;
use inkwell::AddressSpace;
use inkwell::{basic_block, llvm_sys::LLVMValue};

pub trait ToLlvmValue {
    fn to_llvm_value(&self) -> String;
}

pub trait ToLlvmIr {
    unsafe fn to_llvm_ir(&self) -> String;
}

impl ToLlvmIr for ParseTree {
    unsafe fn to_llvm_ir(&self) -> String {
        let context = Context::create();
        let module = context.create_module("abhay");
        let builder = context.create_builder();

        // How to do this dynamically
        let triple = TargetTriple::create("arm64-apple-macosx13.0.0");
        module.set_triple(&triple);


        let i32_type = context.i32_type();
        let char_type = context.i8_type();
        let char_ptr_type = context.ptr_type(AddressSpace::default()).into();
        // BasicMetadataTypeEnum::PointerType(char_type.ptr_type(AddressSpace::default()));


        let print_fn_type = i32_type.fn_type(&[char_ptr_type], true);
        let print_fn = module.add_function("printf", print_fn_type, None);

        // Main function takes no arguments
        let fn_type = i32_type.fn_type(&[], false);
        // declare function
        let fn_value = module.add_function("main", fn_type, None);

        // append new basic block for a specific function
        let entry = context.append_basic_block(fn_value, "entry");


        // First time Builder nees to know where to start from: We start from end of entry basic block
        builder.position_at_end(entry);

        let print_stmnt_ptr = builder.build_global_string("Hello world: %d\n", "print_string").expect("failed to create global string").as_pointer_value().into();
        let i32_arg = i32_type.const_int(0, false);
        let mut print_args = [print_stmnt_ptr,i32_arg.into() ];
        builder.build_call(print_fn, &print_args, "printf");

        // main returns 0
        builder.build_return(Some(&i32_arg)).unwrap();

        return module.print_to_string().to_string();
    }
}
