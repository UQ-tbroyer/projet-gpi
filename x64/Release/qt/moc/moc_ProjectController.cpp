/****************************************************************************
** Meta object code from reading C++ file 'ProjectController.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../ProjectController.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ProjectController.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.8.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN17ProjectControllerE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN17ProjectControllerE = QtMocHelpers::stringData(
    "ProjectController",
    "projectsChanged",
    "",
    "loadingChanged",
    "projectCreated",
    "projectId",
    "projectCreationFailed",
    "error",
    "projectUpdated",
    "projectUpdateFailed",
    "projectDeleted",
    "projectDeletionFailed",
    "clientsLoaded",
    "errorOccurred",
    "currentUserChanged",
    "employeeHoursSaved",
    "employeeId",
    "hours",
    "employeeHoursSaveFailed",
    "errorMessage",
    "createProjectFromPredeterminedTemplate",
    "projectName",
    "clientId",
    "repository",
    "cost",
    "loadProjects",
    "loadProjectsByUser",
    "loadProjectsByDepartment",
    "createProject",
    "projectDate",
    "updateProject",
    "deleteProject",
    "getProjectDetails",
    "QVariantMap",
    "getClients",
    "QVariantList",
    "loadClients",
    "getTemplateProjects",
    "getAllProjectsForTemplate",
    "canCreateProject",
    "canEditProject",
    "canDeleteProject",
    "canViewAllProjects",
    "getUserRole",
    "saveEmployeeHours",
    "getCurrentUserId",
    "projects",
    "loading"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN17ProjectControllerE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      33,   14, // methods
       2,  315, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
      13,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,  212,    2, 0x06,    3 /* Public */,
       3,    0,  213,    2, 0x06,    4 /* Public */,
       4,    1,  214,    2, 0x06,    5 /* Public */,
       6,    1,  217,    2, 0x06,    7 /* Public */,
       8,    1,  220,    2, 0x06,    9 /* Public */,
       9,    1,  223,    2, 0x06,   11 /* Public */,
      10,    1,  226,    2, 0x06,   13 /* Public */,
      11,    1,  229,    2, 0x06,   15 /* Public */,
      12,    0,  232,    2, 0x06,   17 /* Public */,
      13,    1,  233,    2, 0x06,   18 /* Public */,
      14,    0,  236,    2, 0x06,   20 /* Public */,
      15,    3,  237,    2, 0x06,   21 /* Public */,
      18,    1,  244,    2, 0x06,   25 /* Public */,

 // slots: name, argc, parameters, tag, flags, initial metatype offsets
      20,    4,  247,    2, 0x0a,   27 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
      25,    0,  256,    2, 0x02,   32 /* Public */,
      26,    0,  257,    2, 0x02,   33 /* Public */,
      27,    0,  258,    2, 0x02,   34 /* Public */,
      28,    5,  259,    2, 0x02,   35 /* Public */,
      28,    4,  270,    2, 0x22,   41 /* Public | MethodCloned */,
      30,    4,  279,    2, 0x02,   46 /* Public */,
      31,    1,  288,    2, 0x02,   51 /* Public */,
      32,    1,  291,    2, 0x02,   53 /* Public */,
      34,    0,  294,    2, 0x02,   55 /* Public */,
      36,    0,  295,    2, 0x02,   56 /* Public */,
      37,    0,  296,    2, 0x02,   57 /* Public */,
      38,    0,  297,    2, 0x02,   58 /* Public */,
      39,    0,  298,    2, 0x102,   59 /* Public | MethodIsConst  */,
      40,    1,  299,    2, 0x102,   60 /* Public | MethodIsConst  */,
      41,    1,  302,    2, 0x102,   62 /* Public | MethodIsConst  */,
      42,    0,  305,    2, 0x102,   64 /* Public | MethodIsConst  */,
      43,    0,  306,    2, 0x102,   65 /* Public | MethodIsConst  */,
      44,    3,  307,    2, 0x02,   66 /* Public */,
      45,    0,  314,    2, 0x02,   70 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    5,
    QMetaType::Void, QMetaType::QString,    7,
    QMetaType::Void, QMetaType::Int,    5,
    QMetaType::Void, QMetaType::QString,    7,
    QMetaType::Void, QMetaType::Int,    5,
    QMetaType::Void, QMetaType::QString,    7,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    7,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int, QMetaType::Int, QMetaType::Double,    5,   16,   17,
    QMetaType::Void, QMetaType::QString,   19,

 // slots: parameters
    QMetaType::Bool, QMetaType::QString, QMetaType::Int, QMetaType::QString, QMetaType::Double,   21,   22,   23,   24,

 // methods: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int, QMetaType::QString, QMetaType::Double, QMetaType::QString,   21,   22,   23,   24,   29,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int, QMetaType::QString, QMetaType::Double,   21,   22,   23,   24,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Double,    5,   21,   23,   24,
    QMetaType::Bool, QMetaType::Int,    5,
    0x80000000 | 33, QMetaType::Int,    5,
    0x80000000 | 35,
    QMetaType::Void,
    0x80000000 | 35,
    0x80000000 | 35,
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::Int,    5,
    QMetaType::Bool, QMetaType::Int,    5,
    QMetaType::Bool,
    QMetaType::QString,
    QMetaType::Bool, QMetaType::Int, QMetaType::Int, QMetaType::Double,    5,   16,   17,
    QMetaType::Int,

 // properties: name, type, flags, notifyId, revision
      46, 0x80000000 | 35, 0x00015009, uint(0), 0,
      47, QMetaType::Bool, 0x00015001, uint(1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject ProjectController::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ZN17ProjectControllerE.offsetsAndSizes,
    qt_meta_data_ZN17ProjectControllerE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN17ProjectControllerE_t,
        // property 'projects'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // property 'loading'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<ProjectController, std::true_type>,
        // method 'projectsChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'loadingChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'projectCreated'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'projectCreationFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'projectUpdated'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'projectUpdateFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'projectDeleted'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'projectDeletionFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'clientsLoaded'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'errorOccurred'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'currentUserChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'employeeHoursSaved'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'employeeHoursSaveFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'createProjectFromPredeterminedTemplate'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'loadProjects'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'loadProjectsByUser'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'loadProjectsByDepartment'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'createProject'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'createProject'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'updateProject'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'deleteProject'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getProjectDetails'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getClients'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'loadClients'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'getTemplateProjects'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'getAllProjectsForTemplate'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'canCreateProject'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'canEditProject'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'canDeleteProject'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'canViewAllProjects'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'getUserRole'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>,
        // method 'saveEmployeeHours'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'getCurrentUserId'
        QtPrivate::TypeAndForceComplete<int, std::false_type>
    >,
    nullptr
} };

void ProjectController::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<ProjectController *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->projectsChanged(); break;
        case 1: _t->loadingChanged(); break;
        case 2: _t->projectCreated((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 3: _t->projectCreationFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 4: _t->projectUpdated((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 5: _t->projectUpdateFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 6: _t->projectDeleted((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 7: _t->projectDeletionFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 8: _t->clientsLoaded(); break;
        case 9: _t->errorOccurred((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 10: _t->currentUserChanged(); break;
        case 11: _t->employeeHoursSaved((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3]))); break;
        case 12: _t->employeeHoursSaveFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 13: { bool _r = _t->createProjectFromPredeterminedTemplate((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 14: _t->loadProjects(); break;
        case 15: _t->loadProjectsByUser(); break;
        case 16: _t->loadProjectsByDepartment(); break;
        case 17: { bool _r = _t->createProject((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 18: { bool _r = _t->createProject((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 19: { bool _r = _t->updateProject((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 20: { bool _r = _t->deleteProject((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 21: { QVariantMap _r = _t->getProjectDetails((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 22: { QVariantList _r = _t->getClients();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 23: _t->loadClients(); break;
        case 24: { QVariantList _r = _t->getTemplateProjects();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 25: { QVariantList _r = _t->getAllProjectsForTemplate();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 26: { bool _r = _t->canCreateProject();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 27: { bool _r = _t->canEditProject((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 28: { bool _r = _t->canDeleteProject((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 29: { bool _r = _t->canViewAllProjects();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 30: { QString _r = _t->getUserRole();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 31: { bool _r = _t->saveEmployeeHours((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 32: { int _r = _t->getCurrentUserId();
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _q_method_type = void (ProjectController::*)();
            if (_q_method_type _q_method = &ProjectController::projectsChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)();
            if (_q_method_type _q_method = &ProjectController::loadingChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)(int );
            if (_q_method_type _q_method = &ProjectController::projectCreated; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)(const QString & );
            if (_q_method_type _q_method = &ProjectController::projectCreationFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)(int );
            if (_q_method_type _q_method = &ProjectController::projectUpdated; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)(const QString & );
            if (_q_method_type _q_method = &ProjectController::projectUpdateFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 5;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)(int );
            if (_q_method_type _q_method = &ProjectController::projectDeleted; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 6;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)(const QString & );
            if (_q_method_type _q_method = &ProjectController::projectDeletionFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 7;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)();
            if (_q_method_type _q_method = &ProjectController::clientsLoaded; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 8;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)(const QString & );
            if (_q_method_type _q_method = &ProjectController::errorOccurred; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 9;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)();
            if (_q_method_type _q_method = &ProjectController::currentUserChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 10;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)(int , int , double );
            if (_q_method_type _q_method = &ProjectController::employeeHoursSaved; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 11;
                return;
            }
        }
        {
            using _q_method_type = void (ProjectController::*)(const QString & );
            if (_q_method_type _q_method = &ProjectController::employeeHoursSaveFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 12;
                return;
            }
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QVariantList*>(_v) = _t->projects(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->loading(); break;
        default: break;
        }
    }
}

const QMetaObject *ProjectController::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ProjectController::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ZN17ProjectControllerE.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int ProjectController::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 33)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 33;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 33)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 33;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    }
    return _id;
}

// SIGNAL 0
void ProjectController::projectsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void ProjectController::loadingChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void ProjectController::projectCreated(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void ProjectController::projectCreationFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void ProjectController::projectUpdated(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void ProjectController::projectUpdateFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void ProjectController::projectDeleted(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}

// SIGNAL 7
void ProjectController::projectDeletionFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 7, _a);
}

// SIGNAL 8
void ProjectController::clientsLoaded()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void ProjectController::errorOccurred(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 9, _a);
}

// SIGNAL 10
void ProjectController::currentUserChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 10, nullptr);
}

// SIGNAL 11
void ProjectController::employeeHoursSaved(int _t1, int _t2, double _t3)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t3))) };
    QMetaObject::activate(this, &staticMetaObject, 11, _a);
}

// SIGNAL 12
void ProjectController::employeeHoursSaveFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 12, _a);
}
QT_WARNING_POP
