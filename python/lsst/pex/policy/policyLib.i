// -*- lsst-c++ -*-
%define policy_DOCSTRING
"
Access to the policy classes from the pex module
"
%enddef

%feature("autodoc", "1");
%module(package="lsst.pex.policy", docstring=policy_DOCSTRING) policyLib

// Supress warnings
#pragma SWIG nowarn=314     // print is a python keyword (--> _print)


%{
#include "lsst/daf/base.h"
#include "lsst/pex/policy/exceptions.h"
#include "lsst/pex/policy/parserexceptions.h"
#include "lsst/pex/policy/Policy.h"
#include "lsst/pex/policy/PolicyFile.h"
#include "lsst/pex/policy/paf/PAFWriter.h"
#include <sstream>

using lsst::pex::policy::SupportedFormats;
using lsst::pex::policy::PolicyParserFactory;
%}

%inline %{
namespace boost { namespace filesystem { } }
%}

// For now, pex_policy does not use the standard LSST exception classes,
// so disable the associated SWIG exception handling machinery
// #define NO_SWIG_LSST_EXCEPTIONS

%include "lsst/p_lsstSwig.i"

%import "lsst/daf/base/baseLib.i"
%import "lsst/pex/exceptions/exceptionsLib.i"    // for Exceptions

%typemap(out) std::vector<double,std::allocator<double > >& {
    int len = (*$1).size();
    $result = PyList_New(len);
    for (int i = 0; i < len; i++) {
        PyList_SetItem($result,i,PyFloat_FromDouble((*$1)[i]));
    }
}

%typemap(out) std::vector<int,std::allocator<int > >& {
    int len = (*$1).size();
    $result = PyList_New(len);
    for (int i = 0; i < len; i++) {
        PyList_SetItem($result,i,PyInt_FromLong((*$1)[i]));
    }
}

%typemap(out) std::vector<boost::shared_ptr<std::string > >& {
    int len = (*$1).size();
    $result = PyList_New(len);
    for (int i = 0; i < len; i++) {
        PyList_SetItem($result,i,PyString_FromString((*$1)[i]->c_str()));
    }
}

%typemap(out) std::vector<bool,std::allocator<bool > >& {
    int len = (*$1).size();
    $result = PyList_New(len);
    for (int i = 0; i < len; i++) {
        PyList_SetItem($result,i, ( ((*$1)[i]) ? Py_True : Py_False ) );
    }
}

%typemap(out) std::vector<boost::shared_ptr<lsst::pex::policy::Policy > >& {
    int len = (*$1).size();
    $result = PyList_New(len);
    for (int i = 0; i < len; i++) {
        boost::shared_ptr<lsst::pex::policy::Policy> * smartresult =
            new boost::shared_ptr<lsst::pex::policy::Policy>((*$1)[i]);
        PyObject * obj = SWIG_NewPointerObj(SWIG_as_voidptr(smartresult),
            SWIGTYPE_p_boost__shared_ptrT_lsst__pex__policy__Policy_t,
            SWIG_POINTER_OWN);
        PyList_SetItem($result, i, obj);
    }
}

%typemap(out) std::vector<boost::shared_ptr<lsst::pex::policy::PolicyFile > >& {
    int len = (*$1).size();
    $result = PyList_New(len);
    for (int i = 0; i < len; i++) {
        boost::shared_ptr<lsst::pex::policy::PolicyFile> * smartresult =
            new boost::shared_ptr<lsst::pex::policy::PolicyFile>((*$1)[i]);
        PyObject * obj = SWIG_NewPointerObj(SWIG_as_voidptr(smartresult),
            SWIGTYPE_p_boost__shared_ptrT_lsst__pex__policy__PolicyFile_t,
            SWIG_POINTER_OWN);
        PyList_SetItem($result, i, obj);
    }
}

%typemap(in,numinputs=0) std::list<std::string > &names (std::list<std::string > temp) {
    $1 = &temp;
}

%template(NameList) std::list<std::string >;

SWIG_SHARED_PTR(Policy, lsst::pex::policy::Policy)
SWIG_SHARED_PTR(PolicySource, lsst::pex::policy::PolicySource)
SWIG_SHARED_PTR_DERIVED(PolicyFile, lsst::pex::policy::PolicySource, lsst::pex::policy::PolicyFile)

%newobject lsst::pex::policy::Policy::createPolicy;
%feature("notabstract") lsst::pex::policy::paf::PAFWriter;

%ignore lsst::pex::policy::Policy::Policy(const Policy& pol);

// there is perhaps a better way to deal with this
%ignore lsst::pex::policy::Policy::names(std::list<std::string>& names, bool topLevelOnly, bool append);
%ignore lsst::pex::policy::Policy::paramNames(std::list<std::string>& names, bool topLevelOnly, bool append);
%ignore lsst::pex::policy::Policy::policyNames(std::list<std::string>& names, bool topLevelOnly, bool append);
%ignore lsst::pex::policy::Policy::fileNames(std::list<std::string>& names, bool topLevelOnly, bool append);
%ignore lsst::pex::policy::Policy::names(std::list<std::string,std::allocator< std::string > >& names, bool topLevelOnly);
%ignore lsst::pex::policy::Policy::paramNames(std::list<std::string>& names, bool topLevelOnly);
%ignore lsst::pex::policy::Policy::policyNames(std::list<std::string>& names, bool topLevelOnly);
%ignore lsst::pex::policy::Policy::fileNames(std::list<std::string>& names, bool topLevelOnly);
%ignore lsst::pex::policy::Policy::names(std::list<std::string>& names);
%ignore lsst::pex::policy::Policy::paramNames(std::list<std::string>& names);
%ignore lsst::pex::policy::Policy::policyNames(std::list<std::string>& names);
%ignore lsst::pex::policy::Policy::fileNames(std::list<std::string>& names);

%include "lsst/pex/policy/Policy.h"
%include "lsst/pex/policy/PolicyWriter.h"
%include "lsst/pex/policy/paf/PAFWriter.h"
%include "lsst/pex/policy/exceptions.h"
%include "lsst/pex/policy/parserexceptions.h"

%extend lsst::pex::policy::Policy {
    void _setBool(const std::string& name, bool value) {
       self->set(name, value);
    }

    void _addBool(const std::string& name, bool value) {
       self->add(name, value);
    }
}

%pythoncode %{
Policy.__str__ = Policy.toString

def _Policy_get(p, name, defval=None):
    type = p.getValueType(name);
    if (type == p.UNDEF):  return defval

    if (type == p.INT):
        return p.getInt(name)
    elif (type == p.DOUBLE):
        return p.getDouble(name)
    elif (type == p.BOOL):
        return p.getBool(name)
    elif (type == p.STRING):
        return p.getString(name)
    elif (type == p.POLICY):
        return p.getPolicy(name)

def _Policy_getArray(p, name):
    type = p.getValueType(name);
    if (type == p.UNDEF):  return None

    if (type == p.INT):
        return p.getIntArray(name)
    elif (type == p.DOUBLE):
        return p.getDoubleArray(name)
    elif (type == p.BOOL):
        return p.getBoolArray(name)
    elif (type == p.STRING):
        return p.getStringArray(name)
    elif (type == p.POLICY):
        return p.getPolicyArray(name)

Policy.get = _Policy_get
Policy.getArray = _Policy_getArray

_Policy_wrap_set = Policy.set
def _Policy_set(p, name, value):
    if isinstance(value, bool):
        p._setBool(name, value)
    else:
        _Policy_wrap_set(p, name, value)
Policy.set = _Policy_set

_Policy_wrap_add = Policy.add
def _Policy_add(p, name, value):
    if isinstance(value, bool):
        p._addBool(name, value)
    else:
        _Policy_wrap_add(p, name, value)
Policy.add = _Policy_add
%}

%ignore lsst::pex::policy::PolicySource::defaultFormats;
%include "lsst/pex/policy/PolicySource.h"
%include "lsst/pex/policy/PolicyFile.h"

