use crate::parser::ParseTree;
use inkwell::builder::{Builder, BuilderError};
use inkwell::context::Context;
use inkwell::module::Module;
use inkwell::{basic_block, llvm_sys::LLVMValue};

pub trait ToLlvmValue {
    fn to_llvm_value(&self) -> String;
}

pub trait ToLlvmIr {
    fn to_llvm_ir(&self) -> String;
}

impl ToLlvmIr for ParseTree {
    fn to_llvm_ir(&self) -> String {
        let context = Context::create();
        let module = context.create_module("abhay");
        let builder = context.create_builder();
        let i32_type = context.i32_type();
        let arg_types = [i32_type.into()];
        let fn_type = i32_type.fn_type(&arg_types, false);
        let fn_value = module.add_function("ret", fn_type, None);
        let entry = context.append_basic_block(fn_value, "entry");
        let i32_arg = fn_value.get_first_param().unwrap();

        builder.position_at_end(entry);
        builder.build_return(Some(&i32_arg)).unwrap();

        return module.print_to_string().to_string();
    }
}
